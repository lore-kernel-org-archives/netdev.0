From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: [PATCH v4 10/20] selftests/mount: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:24 -0700
Message-ID: <e9ad7dee751cb83d358ddc7e2949e312db9db1ed.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mmarek-AlSwsSmVLrQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1420571615.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
In-Reply-To: <cover.1420571615.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
References: <cover.1420571615.git.shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 tools/testing/selftests/mount/Makefile | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/mount/Makefile b/tools/testing/selftests/mount/Makefile
index 337d853..422a2d8 100644
--- a/tools/testing/selftests/mount/Makefile
+++ b/tools/testing/selftests/mount/Makefile
@@ -1,5 +1,7 @@
 # Makefile for mount selftests.
 
+TEST_STR = if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+
 all: unprivileged-remount-test
 
 unprivileged-remount-test: unprivileged-remount-test.c
@@ -7,7 +9,15 @@ unprivileged-remount-test: unprivileged-remount-test.c
 
 # Allow specific tests to be selected.
 test_unprivileged_remount: unprivileged-remount-test
-	@if [ -f /proc/self/uid_map ] ; then ./unprivileged-remount-test ; fi
+	@$(TEST_STR)
+
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./unprivileged-remount-test $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
 
 run_tests: all test_unprivileged_remount
 
-- 
2.1.0
