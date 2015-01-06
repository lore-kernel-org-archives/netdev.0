From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 04/20] selftests/firmware: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:18 -0700
Message-ID: <84932e435fdf85cbbec62b35210d33178321a2a4.1420571615.git.shuahkh@osg.samsung.com>
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
Received: from resqmta-ch2-07v.sys.comcast.net ([69.252.207.39]:48430 "EHLO
	resqmta-ch2-07v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932917AbbAFTwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:52:04 -0500
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
 tools/testing/selftests/firmware/Makefile | 43 +++++++++++++++++++------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/tools/testing/selftests/firmware/Makefile b/tools/testing/selftests/firmware/Makefile
index e23cce0..0bdc25b 100644
--- a/tools/testing/selftests/firmware/Makefile
+++ b/tools/testing/selftests/firmware/Makefile
@@ -1,25 +1,34 @@
 # Makefile for firmware loading selftests
 
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
+
+__fw_filesystem:
+fw_filesystem  = if /bin/sh ./fw_filesystem.sh ; then
+fw_filesystem += echo 'fw_filesystem: ok';
+fw_filesystem += else echo 'fw_filesystem: [FAIL]';
+fw_filesystem += fi
+
+__fw_userhelper:
+fw_userhelper  = if /bin/sh ./fw_userhelper.sh ; then
+fw_userhelper += echo 'fw_userhelper: ok';
+fw_userhelper += else
+fw_userhelper += echo 'fw_userhelper: [FAIL]';
+fw_userhelper += fi
+
 all:
 
-fw_filesystem:
-	@if /bin/sh ./fw_filesystem.sh ; then \
-                echo "fw_filesystem: ok"; \
-        else \
-                echo "fw_filesystem: [FAIL]"; \
-                exit 1; \
-        fi
-
-fw_userhelper:
-	@if /bin/sh ./fw_userhelper.sh ; then \
-                echo "fw_userhelper: ok"; \
-        else \
-                echo "fw_userhelper: [FAIL]"; \
-                exit 1; \
-        fi
-
-run_tests: all fw_filesystem fw_userhelper
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./fw_filesystem.sh ./fw_userhelper.sh $(INSTALL_KSFT_PATH)
+	@echo "$(fw_filesystem)" >> $(KSELFTEST)
+	@echo "$(fw_userhelper)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
+run_tests:
+	@$(fw_filesystem)
+	@$(fw_userhelper)
 
 # Nothing to clean up.
 clean:
-- 
2.1.0
