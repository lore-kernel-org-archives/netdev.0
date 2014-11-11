From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 14/19] selftests/net: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:54 -0700
Message-ID: <1170d5a224521d8d4840b3f54db60da4c50aa5cc.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level source dir.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/net/Makefile | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 62f22cc..16550eb 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -6,14 +6,31 @@ CFLAGS = -Wall -O2 -g
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
+	@echo echo Start net test .... >> $(KSELFTEST)
+	@echo "$(NETSOCK_TEST_STR)" >> $(KSELFTEST)
+	@echo "$(AFPKT_TEST_STR)" >> $(KSELFTEST)
+	@echo "$(BFP_TEST_STR)" >> $(KSELFTEST)
+	@echo echo End net test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
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
1.9.1
