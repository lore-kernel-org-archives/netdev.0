From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 12/20] selftests/net: add install target to enable test install
Date: Wed, 24 Dec 2014 09:27:48 -0700
Message-ID: <a9e90a4ce816013dc701684feb2bfc29c04064c8.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/net/Makefile | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 62f22cc..2ffc96f 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -6,14 +6,28 @@ CFLAGS = -Wall -O2 -g
 CFLAGS += -I../../../../usr/include/
 
 NET_PROGS = socket psock_fanout psock_tpacket
+INSTALL_PROGS = run_netsocktests run_afpackettests test_bpf.sh $(NET_PROGS)
+NETSOCK_TEST_STR = /bin/sh ./run_netsocktests || echo sockettests: [FAIL]
+AFPKT_TEST_STR = /bin/sh ./run_afpackettests || echo afpackettests: [FAIL]
+BFP_TEST_STR = ./test_bpf.sh
 
 all: $(NET_PROGS)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install $(INSTALL_PROGS) $(INSTALL_KSFT_PATH)
+	@echo "$(NETSOCK_TEST_STR)" >> $(KSELFTEST)
+	@echo "$(AFPKT_TEST_STR)" >> $(KSELFTEST)
+	@echo "$(BFP_TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
 run_tests: all
-	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
-	@/bin/sh ./run_afpackettests || echo "afpackettests: [FAIL]"
-	./test_bpf.sh
+	@$(NETSOCK_TEST_STR)
+	@$(AFPKT_TEST_STR)
+	@$(BFP_TEST_STR)
 clean:
 	$(RM) $(NET_PROGS)
-- 
2.1.0
