From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: concurrent rhashtable test failure
Date: Mon, 24 Oct 2016 14:11:32 +0200
Message-ID: <CAMuHMdWTqXaJAM-O+mmha=JbuyvvNxYyHuV6e4YK7oUkh9rCkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Phil,

On m68k/ARAnyM, test_rhashtable fails with:

    Test failed: thread 0 returned: -4

(-4 = -EINTR)

I traced this back to your commit f4a3e90ba5739cfd ("rhashtable-test: extend
to test concurrency"), which added that part of the test.

Diff of the test output between the failing commit and its parent:

 Running rhashtable test nelem=8, max_size=65536, shrinking=0
 Test 00:
   Adding 50000 keys
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Deleting 50000 keys
-  Duration of test: 1029960000 ns
+  Duration of test: 990000000 ns
 Test 01:
   Adding 50000 keys
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Deleting 50000 keys
-  Duration of test: 990000000 ns
+  Duration of test: 720000000 ns
 Test 02:
   Adding 50000 keys
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Deleting 50000 keys
-  Duration of test: 1130000000 ns
+  Duration of test: 700000000 ns
 Test 03:
   Adding 50000 keys
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
   Deleting 50000 keys
-  Duration of test: 1080000000 ns
-Average test time: 1057490000
+  Duration of test: 700000000 ns
+Average test time: 777500000
+Testing concurrent rhashtable access from 10 threads
+Test failed: thread 0 returned: -4
+Started 10 threads, 1 failed

Do you have any clue?

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
