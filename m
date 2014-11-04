From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 13/20] selftests/mount: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:09 -0700
Message-ID: <313d51c298bb13b7cd9187555ee8a70ee966e397.1415117102.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/mount/Makefile | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 337d853..3bcb112 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -9,6 +9,13 @@ unprivileged-remount-test: unprivileged-remount-test.c
 test_unprivileged_remount: unprivileged-remount-test
 	@if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
 
+install: all
+	install ./unprivileged-remount-test $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start mount test ....\"" >> $(KSELFTEST)
+	echo "if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi" >> $(KSELFTEST)
+	echo "echo \"End mount test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests: all test_unprivileged_remount
 
 clean:
-- 
1.9.1

