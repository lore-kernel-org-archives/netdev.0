From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 07/20] selftests/kcmp: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:21 -0700
Message-ID: <0ef6535b2984b1aa16144dbd06b0779d40bb2dc4.1420571615.git.shuahkh@osg.samsung.com>
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
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/kcmp/Makefile | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/kcmp/Makefile b/tools/testing/selftests/kcmp/Makefile
index ff0eefd..46267c1 100644
--- a/tools/testing/selftests/kcmp/Makefile
+++ b/tools/testing/selftests/kcmp/Makefile
@@ -1,10 +1,21 @@
 CC := $(CROSS_COMPILE)$(CC)
 CFLAGS += -I../../../../usr/include/
 
+TEST_STR = ./kcmp_test || echo 'kcmp_test: [FAIL]'
+
 all: kcmp_test
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./kcmp_test $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+	@echo rm -f kcmp-test-file >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests: all
-	@./kcmp_test || echo "kcmp_test: [FAIL]"
+	@$(TEST_STR)
 
 clean:
 	$(RM) kcmp_test kcmp-test-file
-- 
2.1.0

