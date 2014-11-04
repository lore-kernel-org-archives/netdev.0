From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 06/20] selftests/cpu-hotplug: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:02 -0700
Message-ID: <7b618c4c81043fc6cc8d7b218069100262e544a2.1415117102.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/cpu-hotplug/Makefile | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/tools/testing/selftests/cpu-hotplug/Makefile b/tools/testing/selftests/cpu-hotplug/Makefile
index e9c28d8..3075d3a 100644
--- a/tools/testing/selftests/cpu-hotplug/Makefile
+++ b/tools/testing/selftests/cpu-hotplug/Makefile
@@ -1,5 +1,14 @@
+TEST_STR="/bin/bash ./cpu-on-off-test.sh || echo \"cpu-hotplug selftests: [FAIL]\""
+
 all:
 
+install:
+	install ./on-off-test.sh $(INSTALL_KSFT_PATH)/cpu-on-off-test.sh
+	echo "\necho \"Start cpu hotplug test ....\"" >> $(KSELFTEST)
+	echo $(TEST_STR) >> $(KSELFTEST)
+	echo "echo \"End cpu hotplug test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests:
 	@/bin/bash ./on-off-test.sh || echo "cpu-hotplug selftests: [FAIL]"
 
-- 
1.9.1

