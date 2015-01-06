From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 16/20] selftests/timers: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:30 -0700
Message-ID: <a7d59f0840589027970bec63241bcc084406744d.1420571615.git.shuahkh@osg.samsung.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/timers/Makefile | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/timers/Makefile b/tools/testing/selftests/timers/Makefile
index eb2859f..6c03e92 100644
--- a/tools/testing/selftests/timers/Makefile
+++ b/tools/testing/selftests/timers/Makefile
@@ -1,8 +1,18 @@
+TEST_STR = ./posix_timers
+
 all:
 	gcc posix_timers.c -o posix_timers -lrt
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./posix_timers $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests: all
-	./posix_timers
+	@$(TEST_STR)
 
 clean:
 	rm -f ./posix_timers
-- 
2.1.0
