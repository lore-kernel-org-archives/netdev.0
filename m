From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 13/20] selftests/ptrace: add install target to enable test install
Date: Wed, 24 Dec 2014 09:27:49 -0700
Message-ID: <aa8cd8752e3b0df7a551ef73ed270da99d9d4bd6.1419387513.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/ptrace/Makefile | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/ptrace/Makefile b/tools/testing/selftests/ptrace/Makefile
index 47ae2d3..f238212 100644
--- a/tools/testing/selftests/ptrace/Makefile
+++ b/tools/testing/selftests/ptrace/Makefile
@@ -1,10 +1,20 @@
 CFLAGS += -iquote../../../../include/uapi -Wall
-peeksiginfo: peeksiginfo.c
 
-all: peeksiginfo
+TEST_STR = ./peeksiginfo || echo peeksiginfo selftests: [FAIL]
+
+all:
+	gcc peeksiginfo.c -o peeksiginfo
+
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./peeksiginfo $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
 
 clean:
 	rm -f peeksiginfo
 
 run_tests: all
-	@./peeksiginfo || echo "peeksiginfo selftests: [FAIL]"
+	@$(TEST_STR)
-- 
2.1.0
