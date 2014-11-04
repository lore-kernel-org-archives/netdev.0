From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 05/20] selftests/breakpoints: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:01 -0700
Message-ID: <47902f6867b033618b2821dbf6ab2d89f77a15a8.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/breakpoints/Makefile | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/tools/testing/selftests/breakpoints/Makefile b/tools/testing/selftests/breakpoints/Makefile
index e18b42b..4b4e385 100644
--- a/tools/testing/selftests/breakpoints/Makefile
+++ b/tools/testing/selftests/breakpoints/Makefile
@@ -8,6 +8,7 @@ ifeq ($(ARCH),x86_64)
 	ARCH := x86
 endif
 
+TEST_STR = "./breakpoint_test || echo \"breakpoints selftests: [FAIL]\""
 
 all:
 ifeq ($(ARCH),x86)
@@ -16,6 +17,17 @@ else
 	echo "Not an x86 target, can't build breakpoints selftests"
 endif
 
+install: all
+ifeq ($(ARCH),x86)
+	install ./breakpoint_test $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start breakpoints test ....\"" >> $(KSELFTEST)
+	echo $(TEST_STR) >> $(KSELFTEST)
+	echo "echo \"End breakpoints test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+else
+	echo "Not an x86 target, can't install breakpoints selftests"
+endif
+
 run_tests:
 	@./breakpoint_test || echo "breakpoints selftests: [FAIL]"
 
-- 
1.9.1
