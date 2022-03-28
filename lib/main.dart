import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

final providerOfFutureFacts = FutureProvider((ref) async {
  final foundFacts = await http.get(Uri.parse('https://catfact.ninja/facts'));

  return foundFacts;
});

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureCatFacts = ref.watch(providerOfFutureFacts);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            // AsyncValue は `.when` を使ってハンドリングする
            child: futureCatFacts.when(
              // 非同期処理が完了すると、取得した `config` が `data` で使用できる
              data: (data) {
                final decodedData = json.decode(data.body);
                List catFactDetails = decodedData['data'];
                return ListView(
                  children: [
                    ...catFactDetails.map(
                      (singleCatFactDetails) {
                        return Container(
                          margin: const EdgeInsets.all(12.0),
                          child: Text(singleCatFactDetails['fact']),
                        );
                      },
                    )
                  ],
                );
              },
              // 非同期処理中は `loading` で指定したWidgetが表示される
              loading: () => const CircularProgressIndicator(),
              // エラーが発生した場合に表示されるWidgetを指定
              error: (error, stack) => const Text('some error here'),
            ),
          ),
        ),
      ),
    );
  }
}
