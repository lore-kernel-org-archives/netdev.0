From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 17/20] selftests/user: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:31 -0700
Message-ID: <d4b50b1de5f5f72337c019a49080a09d0269928a.1420571615.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/user/Makefile | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/user/Makefile b/tools/testing/selftests/user/Makefile
index 12c9d15..3d38308 100644
--- a/tools/testing/selftests/user/Makefile
+++ b/tools/testing/selftests/user/Makefile
@@ -1,7 +1,17 @@
 # Makefile for user memory selftests
 
+TEST_STR = ./test_user_copy.sh
+
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
 all:
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./test_user_copy.sh $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests: all
-	./test_user_copy.sh
+	@$(TEST_STR)
-- 
2.1.0

