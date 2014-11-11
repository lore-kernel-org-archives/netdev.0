From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 12/19] selftests/mount: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:52 -0700
Message-ID: <63e46a7d9157cde01206cd6be43678f85ac4268c.1415735831.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/mount/Makefile | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 337d853..7533097 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -1,5 +1,7 @@
 # Makefile for mount selftests.
 
+TEST_STR = if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+
 all: unprivileged-remount-test
 
 unprivileged-remount-test: unprivileged-remount-test.c
@@ -7,7 +9,18 @@ unprivileged-remount-test: unprivileged-remount-test.c
 
 # Allow specific tests to be selected.
 test_unprivileged_remount: unprivileged-remount-test
-	@if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+	@$(TEST_STR)
+
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./unprivileged-remount-test $(INSTALL_KSFT_PATH)
+	@echo echo Start mount test .... >> $(KSELFTEST)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+	@echo echo End mount test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
 
 run_tests: all test_unprivileged_remount
 
-- 
1.9.1
