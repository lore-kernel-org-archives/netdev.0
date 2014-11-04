From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 17/20] selftests/sysctl: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:13 -0700
Message-ID: <2eeb9fe120aac0bcd50a0644e4b9f81db856ed52.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.201.169]:50541 "EHLO
	mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaKDRSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:18:16 -0500
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/sysctl/Makefile | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tools/testing/selftests/sysctl/Makefile b/tools/testing/selftests/sysctl/Makefile
index 0a92ada..c8d9b2b 100644
--- a/tools/testing/selftests/sysctl/Makefile
+++ b/tools/testing/selftests/sysctl/Makefile
@@ -4,6 +4,8 @@
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests".
 all:
 
+INSTALL_PROGS = common_tests run_numerictests run_stringtests
+
 # Allow specific tests to be selected.
 test_num:
 	@/bin/sh ./run_numerictests
@@ -11,6 +13,14 @@ test_num:
 test_string:
 	@/bin/sh ./run_stringtests
 
+install: all
+	install $(INSTALL_PROGS) $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start sysctl test ....\"" >> $(KSELFTEST)
+	echo "/bin/sh ./run_numerictests" >> $(KSELFTEST)
+	echo "/bin/sh ./run_stringtests" >> $(KSELFTEST)
+	echo "echo \"End sysctl test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests: all test_num test_string
 
 # Nothing to clean up.
-- 
1.9.1
