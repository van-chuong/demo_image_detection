import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Detection App',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Image Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Classifier _classifier;
  bool _loading = true;
  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;

  Category? category;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Text(
                      'Cat Or Dog Classification',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              Center(
                child: _loading ? Container(
                  width: 350,
                  height: 350,
                  child: Image.asset("assets/images/img.png"),
                ) : Column(
                  children: [
                    Container(
                      width: 350,
                      height: 350,
                      child: _imageWidget,
                    ),
                    SizedBox(height: 10,),
                    category!=null?
                        Column(
                          children: [
                            Text("Predict Result: "+ category!.label,style: Theme.of(context).textTheme.titleMedium,),
                            Text("Predict Score: "+ category!.score.toString(),style: Theme.of(context).textTheme.titleMedium,)
                          ],
                        )
                        :Container()
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,20,0,10),
                      child: ElevatedButton(
                          onPressed: () {
                            getImageFromCamera();
                          },
                          child: Text('Capture A Photo')
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0,0,0,10),
                      child: ElevatedButton(
                          onPressed: () {
                            getImage();
                          },
                          child: Text('Select A Photo')
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    _classifier = Classifier( numThreads: 1);
  }
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!= null){
      setState(() {
        _image = File(pickedFile.path);
        _imageWidget = Image.file(_image!);
        _loading = false;
        _predict();
      });
    }
  }

  Future getImageFromCamera() async {
    final pickedFileCamera = await picker.pickImage(source: ImageSource.camera);
    if(pickedFileCamera!= null){
      setState(() {
        _image = File(pickedFileCamera.path);
        _imageWidget = Image.file(_image!);
        _loading = false;
        _predict();
      });
    }
  }
  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);
    setState(() {
      this.category = pred;
    });
  }

}
