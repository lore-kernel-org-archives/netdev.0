From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: [PATCH v4 09/20] selftests/memory-hotplug: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:23 -0700
Message-ID: <8576f564ad9b944e7efe53f5c038ad69c6f392d5.1420571615.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/memory-hotplug/Makefile            | 14 ++++++++++++--
 .../memory-hotplug/{on-off-test.sh => mem-on-off-test.sh}  |  0
 2 files changed, 12 insertions(+), 2 deletions(-)
 rename tools/testing/selftests/memory-hotplug/{on-off-test.sh => mem-on-off-test.sh} (100%)

diff --git a/tools/testing/selftests/memory-hotplug/Makefile b/tools/testing/selftests/memory-hotplug/Makefile
index d46b8d4..3bb0a99 100644
--- a/tools/testing/selftests/memory-hotplug/Makefile
+++ b/tools/testing/selftests/memory-hotplug/Makefile
@@ -1,9 +1,19 @@
+TEST_STR=/bin/bash ./mem-on-off-test.sh -r 2 || echo 'memory-hotplug selftests: [FAIL]'
+
 all:
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./mem-on-off-test.sh $(INSTALL_KSFT_PATH)/mem-on-off-test.sh
+	@echo "$(TEST_STR)" >> $(KSELFTEST) >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests:
-	@/bin/bash ./on-off-test.sh -r 2 || echo "memory-hotplug selftests: [FAIL]"
+	@$(TEST_STR)
 
 run_full_test:
-	@/bin/bash ./on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
+	@/bin/bash ./mem-on-off-test.sh || echo "memory-hotplug selftests: [FAIL]"
 
 clean:
diff --git a/tools/testing/selftests/memory-hotplug/on-off-test.sh b/tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
similarity index 100%
rename from tools/testing/selftests/memory-hotplug/on-off-test.sh
rename to tools/testing/selftests/memory-hotplug/mem-on-off-test.sh
-- 
2.1.0
