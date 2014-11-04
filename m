From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 19/20] selftests/vm: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:15 -0700
Message-ID: <271b880cb8efb17078c090715c6b0c729c61dbbc.1415117102.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/vm/Makefile | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 4c4b1f6..254ce92 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -9,6 +9,13 @@ all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
+install: all
+	install run_vmtests $(BINARIES) $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start vm test ....\"" >> $(KSELFTEST)
+	echo "/bin/sh ./run_vmtests || echo \"vmtests: [FAIL]\"" >> $(KSELFTEST)
+	echo "echo \"End vm test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests: all
 	@/bin/sh ./run_vmtests || (echo "vmtests: [FAIL]"; exit 1)
 
-- 
1.9.1

