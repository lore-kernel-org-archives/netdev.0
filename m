From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 12/20] selftests/net: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:26 -0700
Message-ID: <8fa0f55f4f3687459f018fe25a9e8d6347757c60.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	masami.hiramatsu.pt@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-04v.sys.comcast.net ([69.252.207.36]:50818 "EHLO
	resqmta-ch2-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932939AbbAFTs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:48:58 -0500
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/net/Makefile | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 62f22cc..a1a8253 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -6,14 +6,28 @@ CFLAGS = -Wall -O2 -g
 CFLAGS += -I../../../../usr/include/
 
 NET_PROGS = socket psock_fanout psock_tpacket
+INSTALL_PROGS = run_netsocktests run_afpackettests test_bpf.sh $(NET_PROGS)
+NETSOCK_TEST_STR = /bin/sh ./run_netsocktests || echo 'sockettests: [FAIL]'
+AFPKT_TEST_STR = /bin/sh ./run_afpackettests || echo 'afpackettests: [FAIL]'
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
+	@echo "Run make kselftest_install in top level source directory"
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
