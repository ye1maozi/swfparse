package
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	public class swfparse extends Sprite
	{
		private var _file:File;
		private var _stream:URLStream;
		private var loadercontext:LoaderContext;
		private var _loader:Loader;
		public function swfparse()
		{
			var a:int = getTimer();
			var b:int = a + 2204360000 ;
			if(stage){
				init();
			}else
				addEventListener(Event.ADDED_TO_STAGE,init);
			
		}
		
		protected function init(event:Event=null):void
		{
			// TODO Auto-generated method stub
			_stream = new URLStream();
			_stream.addEventListener( Event.COMPLETE, Stream_OnComplete );
			loadercontext = new LoaderContext();
			loadercontext.allowCodeImport = true;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Loader_OnComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, LoaderBytes_OnError);
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill(0x0,0.1);
			spr.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			spr.graphics.endFill();
			addChild(spr);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDropEnter);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);
		}
		protected function onDropEnter(event:NativeDragEvent):void
		{
			// TODO Auto-generated method stub
			var clip:Clipboard=event.clipboard;
			var path:String= event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT)[0].nativePath;
			var arr:Array= path.split(".");
			var name:String = arr[arr.length-1];
			if (name == "dat" 
				&& clip.hasFormat(flash.desktop.ClipboardFormats.FILE_LIST_FORMAT)) 
			{
				NativeDragManager.acceptDragDrop(this);
			}
		}
		
		protected function onDrop(event:NativeDragEvent):void
		{
			// TODO Auto-generated method stub
			var arr:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			_file = arr[0];
			var r:URLRequest = new URLRequest(_file.url);
			_stream.load(r);
		}
		
		protected function Stream_OnComplete(event:Event):void
		{
			var bytes:ByteArray = new ByteArray();
//			_stream.readBytes(bytes);
			
//			_loader.loadBytes(bytes,loadercontext);
			ReadStream(_stream);
			//			this.LoadClass( bytes, stream.name );
			
		}
		
		public function ReadStream( stream:URLStream):String
		{
			var bytes:ByteArray = new ByteArray();
			//添加swf前三个字节
			bytes.writeByte( 0x43 );
			bytes.writeByte( 0x57 );
			bytes.writeByte( 0x53 );
			var name:String = _file.name;
			var arr:Array = name.split(".");
			var len:int = (arr[arr.length-2]);
			ReadConfusionStream( stream, stream.bytesAvailable, bytes, len );
//			ClassLoader.Instance.LoadClass( bytes );
			
			return null;
		}
		/**
		 * 从数据流中读取数据
		 * @stream 数据流
		 * @bytes 读取数据存放的对象
		 * @params 混殽字节数(int)
		 */
		protected function ReadConfusionStream( stream:URLStream, len:int, bytes:ByteArray, mixCount:int ):void
		{
			var mixLimit:int = 10;
			var ubyte:int = mixCount % mixLimit + mixCount/mixLimit+mixLimit;
			var maxMix:uint = ubyte%(mixLimit*mixLimit);
			if(maxMix==0) {
				maxMix = 24;
			}
			
			var offset:int = bytes.length;
			mixCount = mixCount % maxMix;
			
			if ( mixCount <= 0 )
			{
				mixCount = maxMix;
			}
			stream.readBytes( bytes, offset, mixCount );
			var skipBytes:ByteArray = new ByteArray();
			stream.readBytes( skipBytes, 0, mixCount );
			
			stream.readBytes( bytes, mixCount+offset, len-mixCount*2-( maxMix -mixCount ));
			if( maxMix>mixCount) {
				stream.readBytes( skipBytes, 0, maxMix - mixCount );
			}
			bytes.position = 0;
			
			var name:String = _file.name;
			var fileName:String = name+".swf";			
			var file:File = File.desktopDirectory.resolvePath("text\\"+fileName);
			var fs:FileStream = new FileStream();
			
			fs.open( file, FileMode.WRITE );
			fs.writeBytes(bytes );
			fs.close();
//			_loader.loadBytes(bytes,loadercontext);
		}
		protected function Loader_OnComplete(event:Event):void
		{
			var loaderinfo:LoaderInfo = event.target as LoaderInfo;
			var bytes:ByteArray = loaderinfo.bytes;
			var name:String = _file.name;
			var n:int = name.lastIndexOf(".");
			name = name.substr(0,n);
			var fileName:String = name+".swf";			
			var file:File = File.desktopDirectory.resolvePath("text\\"+fileName);
			var fs:FileStream = new FileStream();
			
			fs.open( file, FileMode.WRITE );
			fs.writeBytes(bytes );
			fs.close();
		}
		private function LoaderBytes_OnError( e:IOErrorEvent ):void {
			trace(e.text);
		}
		
	}
}