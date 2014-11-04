From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 07/20] selftests/efivarfs: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:03 -0700
Message-ID: <3d28ab3098e26044a5ef7f60b620c7dfe66cc3fa.1415117102.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/efivarfs/Makefile | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
index 29e8c6b..a668728 100644
--- a/tools/testing/selftests/efivarfs/Makefile
+++ b/tools/testing/selftests/efivarfs/Makefile
@@ -3,7 +3,18 @@ CFLAGS = -Wall
 
 test_objs = open-unlink create-read
 
-all: $(test_objs)
+TEST_STR = "/bin/bash ./efivarfs.sh || echo \"efivarfs selftests: [FAIL]\""
+
+all:
+	gcc open-unlink.c -o open-unlink
+	gcc create-read.c -o create-read
+
+install: all
+	install ./efivarfs.sh $(test_objs) $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start efivarfs test ....\"" >> $(KSELFTEST)
+	echo $(TEST_STR) >> $(KSELFTEST)
+	echo "echo \"End efivarfs test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
 
 run_tests: all
 	@/bin/bash ./efivarfs.sh || echo "efivarfs selftests: [FAIL]"
-- 
1.9.1

