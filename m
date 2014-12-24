From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 06/20] selftests/ipc: add install target to enable test install
Date: Wed, 24 Dec 2014 09:27:42 -0700
Message-ID: <a813eb98c9e6ae6faac3cad6d3e36472e84c54ad.1419387513.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/ipc/Makefile | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/ipc/Makefile b/tools/testing/selftests/ipc/Makefile
index 74bbefd..b43e8e8 100644
--- a/tools/testing/selftests/ipc/Makefile
+++ b/tools/testing/selftests/ipc/Makefile
@@ -11,6 +11,8 @@ endif
 
 CFLAGS += -I../../../../usr/include/
 
+TEST_STR = ./msgque_test || echo ipc msgque test: [FAIL]
+
 all:
 ifeq ($(ARCH),x86)
 	gcc $(CFLAGS) msgque.c -o msgque_test
@@ -18,8 +20,23 @@ else
 	echo "Not an x86 target, can't build msgque selftest"
 endif
 
+install:
+ifdef INSTALL_KSFT_PATH
+ifeq ($(ARCH),x86)
+	make all
+	install ./msgque_test $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Not an x86 target, unable to install ipc msgque selftests
+endif
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
 run_tests: all
-	./msgque_test
+ifeq ($(ARCH),x86)
+	@$(TEST_STR)
+endif
 
 clean:
 	rm -fr ./msgque_test
-- 
2.1.0
