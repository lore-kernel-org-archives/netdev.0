From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: [PATCH 11/20] selftests/memfd: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:07 -0700
Message-ID: <4217a6df43d64f55fb275adb2925d0618955ea46.1415117102.git.shuahkh@osg.samsung.com>
References: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
In-Reply-To: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
References: <cover.1415117102.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test.

Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 tools/testing/selftests/memfd/Makefile | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tools/testing/selftests/memfd/Makefile b/tools/testing/selftests/memfd/Makefile
index b80cd10..bf03ec03 100644
--- a/tools/testing/selftests/memfd/Makefile
+++ b/tools/testing/selftests/memfd/Makefile
@@ -2,9 +2,19 @@ CFLAGS += -D_FILE_OFFSET_BITS=64
 CFLAGS += -I../../../../include/uapi/
 CFLAGS += -I../../../../include/
 
+INSTALL_PROGS = memfd_test fuse_test run_fuse_test.sh
+
 all:
 	gcc $(CFLAGS) memfd_test.c -o memfd_test
 
+install: all build_fuse
+	install $(INSTALL_PROGS) $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start memfd test ....\"" >> $(KSELFTEST)
+	echo "./memfd_test || echo \"memfd_test: [FAIL]\"" >> $(KSELFTEST)
+	echo "./run_fuse_test.sh || echo \"fuse_test: [FAIL]\"" >> $(KSELFTEST)
+	echo "echo \"End memfd test ....\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests: all
 	gcc $(CFLAGS) memfd_test.c -o memfd_test
 	@./memfd_test || echo "memfd_test: [FAIL]"
-- 
1.9.1
