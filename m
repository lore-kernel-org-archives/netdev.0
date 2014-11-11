From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 18/19] selftests/vm: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:58 -0700
Message-ID: <86ae024c4591a8775f82975b69182fdc29f234d2.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.easymail.ca ([64.68.201.169]:48150 "EHLO
	mailout.easymail.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbaKKU2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:28:30 -0500
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level source dir.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/vm/Makefile | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 4c4b1f6..7fbe551 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -4,13 +4,25 @@ CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
 BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbfstest
 BINARIES += transhuge-stress
+TEST_STR = /bin/sh ./run_vmtests || echo vmtests: [FAIL]
 
 all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install run_vmtests $(BINARIES) $(INSTALL_KSFT_PATH)
+	@echo echo Start vm test .... >> $(KSELFTEST)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+	@echo echo End vm test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
 run_tests: all
-	@/bin/sh ./run_vmtests || (echo "vmtests: [FAIL]"; exit 1)
+	@$(TEST_STR)
 
 clean:
 	$(RM) $(BINARIES)
-- 
1.9.1
