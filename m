From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 10/20] selftests/mount: add install target to enable test install
Date: Wed, 24 Dec 2014 09:27:46 -0700
Message-ID: <79fc8be2721f4b035bee4610ff5ba08da4422d7d.1419387513.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/mount/Makefile | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 337d853..607de4c 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -1,5 +1,7 @@
 # Makefile for mount selftests.
 
+TEST_STR = if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+
 all: unprivileged-remount-test
 
 unprivileged-remount-test: unprivileged-remount-test.c
@@ -7,7 +9,15 @@ unprivileged-remount-test: unprivileged-remount-test.c
 
 # Allow specific tests to be selected.
 test_unprivileged_remount: unprivileged-remount-test
-	@if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+	@$(TEST_STR)
+
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./unprivileged-remount-test $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
 
 run_tests: all test_unprivileged_remount
 
-- 
2.1.0
