From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 06/19] selftests/efivarfs: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:46 -0700
Message-ID: <f37035baef13b3a585170e06c26073892897eef8.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1415735831.git.shuahkh@osg.samsung.com>
References: <cover.1415735831.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level source dir.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/efivarfs/Makefile | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
index 29e8c6b..d34c4c2 100644
--- a/tools/testing/selftests/efivarfs/Makefile
+++ b/tools/testing/selftests/efivarfs/Makefile
@@ -3,10 +3,25 @@ CFLAGS = -Wall
 
 test_objs = open-unlink create-read
 
-all: $(test_objs)
+TEST_STR = /bin/bash ./efivarfs.sh || echo efivarfs selftests: [FAIL]
+
+all:
+	gcc open-unlink.c -o open-unlink
+	gcc create-read.c -o create-read
+
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./efivarfs.sh $(test_objs) $(INSTALL_KSFT_PATH)
+	@echo echo Start efivarfs test .... >> $(KSELFTEST)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+	@echo echo End efivarfs test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
 
 run_tests: all
-	@/bin/bash ./efivarfs.sh || echo "efivarfs selftests: [FAIL]"
+	@$(TEST_STR)
 
 clean:
 	rm -f $(test_objs)
-- 
1.9.1
