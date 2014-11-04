From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 10/20] selftests/kcmp: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:06 -0700
Message-ID: <1dc6f2a853bd645cdb64b904b5a3b90ff7be9ad2.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/kcmp/Makefile | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/tools/testing/selftests/kcmp/Makefile b/tools/testing/selftests/kcmp/Makefile
index 8aabd82..e105619 100644
--- a/tools/testing/selftests/kcmp/Makefile
+++ b/tools/testing/selftests/kcmp/Makefile
@@ -21,6 +21,18 @@ else
 	echo "Not an x86 target, can't build kcmp selftest"
 endif
 
+install: all
+ifeq ($(ARCH),x86)
+	install ./kcmp_test $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start kcmp test ....\"" >> $(KSELFTEST)
+	echo "./kcmp_test || echo \"kcmp_test: [FAIL]\"" >> $(KSELFTEST)
+	echo "rm -f kcmp-test-file" >> $(KSELFTEST)
+	echo "echo \"End kcmp test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+else
+	echo "Not an x86 target, can't install kcmp selftests"
+endif
+
 run_tests: all
 	@./kcmp_test || echo "kcmp_test: [FAIL]"
 
-- 
1.9.1

