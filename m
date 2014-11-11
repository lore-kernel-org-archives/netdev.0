From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 10/19] selftests/memfd: add install target to enable installing test
Date: Tue, 11 Nov 2014 13:27:50 -0700
Message-ID: <27fd43900bb72444938011d47c4bd28b3a2de6b9.1415735831.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/memfd/Makefile | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
index b80cd10..a9e06cc 100644
--- a/tools/testing/selftests/memfd/Makefile
+++ b/tools/testing/selftests/memfd/Makefile
@@ -2,19 +2,33 @@ CFLAGS += -D_FILE_OFFSET_BITS=64
 CFLAGS += -I../../../../include/uapi/
 CFLAGS += -I../../../../include/
 
+INSTALL_PROGS = memfd_test fuse_test run_fuse_test.sh
+MEMFD_TEST_STR = ./memfd_test || echo memfd_test: [FAIL]
+FUSE_TEST_STR = ./run_fuse_test.sh || echo fuse_test: [FAIL]
+
 all:
 	gcc $(CFLAGS) memfd_test.c -o memfd_test
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install $(INSTALL_PROGS) $(INSTALL_KSFT_PATH)
+	@echo echo Start memfd test .... >> $(KSELFTEST)
+	@echo "$(MEMFD_TEST_STR)" >> $(KSELFTEST)
+	@echo echo End memfd test .... >> $(KSELFTEST)
+	@echo echo ============================== >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
 run_tests: all
-	gcc $(CFLAGS) memfd_test.c -o memfd_test
-	@./memfd_test || echo "memfd_test: [FAIL]"
+	@$(MEMFD_TEST_STR)
 
 build_fuse:
 	gcc $(CFLAGS) fuse_mnt.c `pkg-config fuse --cflags --libs` -o fuse_mnt
 	gcc $(CFLAGS) fuse_test.c -o fuse_test
 
 run_fuse: build_fuse
-	@./run_fuse_test.sh || echo "fuse_test: [FAIL]"
+	@$(FUSE_TEST_STR)
 
 clean:
 	$(RM) memfd_test fuse_test
-- 
1.9.1
