From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 02/20] selftests/cpu-hotplug: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:16 -0700
Message-ID: <83e299d0172fa4487f8cd6db6c529fbbc8ff2ca5.1420571615.git.shuahkh@osg.samsung.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-04v.sys.comcast.net ([96.114.154.163]:46698 "EHLO
	resqmta-po-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756605AbbAFTvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:51:46 -0500
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/cpu-hotplug/Makefile               | 14 ++++++++++++--
 .../cpu-hotplug/{on-off-test.sh => cpu-on-off-test.sh}     |  0
 2 files changed, 12 insertions(+), 2 deletions(-)
 rename tools/testing/selftests/cpu-hotplug/{on-off-test.sh => cpu-on-off-test.sh} (100%)

diff --git a/tools/testing/selftests/cpu-hotplug/Makefile b/tools/testing/selftests/cpu-hotplug/Makefile
index e9c28d8..c168033 100644
--- a/tools/testing/selftests/cpu-hotplug/Makefile
+++ b/tools/testing/selftests/cpu-hotplug/Makefile
@@ -1,9 +1,19 @@
+TEST_STR=/bin/bash ./cpu-on-off-test.sh || echo 'cpu-hotplug selftests: [FAIL]'
+
 all:
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./cpu-on-off-test.sh $(INSTALL_KSFT_PATH)/cpu-on-off-test.sh
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests:
-	@/bin/bash ./on-off-test.sh || echo "cpu-hotplug selftests: [FAIL]"
+	@$(TEST_STR)
 
 run_full_test:
-	@/bin/bash ./on-off-test.sh -a || echo "cpu-hotplug selftests: [FAIL]"
+	@/bin/bash ./cpu-on-off-test.sh -a || echo "cpu-hotplug selftests: [FAIL]"
 
 clean:
diff --git a/tools/testing/selftests/cpu-hotplug/on-off-test.sh b/tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh
similarity index 100%
rename from tools/testing/selftests/cpu-hotplug/on-off-test.sh
rename to tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh
-- 
2.1.0
