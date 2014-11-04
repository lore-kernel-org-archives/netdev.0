From: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: [PATCH 14/20] selftests/mqueue: add install target to enable installing test
Date: Tue,  4 Nov 2014 10:11:10 -0700
Message-ID: <05a2c2d380f841eb25d5840edccb6778541af832.1415117102.git.shuahkh@osg.samsung.com>
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
 tools/testing/selftests/mqueue/Makefile | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/testing/selftests/mqueue/Makefile b/tools/testing/selftests/mqueue/Makefile
index 8056e2e..b0b5ef7 100644
--- a/tools/testing/selftests/mqueue/Makefile
+++ b/tools/testing/selftests/mqueue/Makefile
@@ -2,6 +2,14 @@ all:
 	gcc -O2 mq_open_tests.c -o mq_open_tests -lrt
 	gcc -O2 -o mq_perf_tests mq_perf_tests.c -lrt -lpthread -lpopt
 
+install: all
+	install ./mq_open_tests $(INSTALL_KSFT_PATH)
+	install ./mq_perf_tests $(INSTALL_KSFT_PATH)
+	echo "\necho \"Start mqueue test ....\"" >> $(KSELFTEST)
+	echo "./mq_open_tests /test1 || echo \"mq_open_tests: [FAIL]\"" >> $(KSELFTEST)
+	echo "./mq_perf_tests || echo \"mq_perf_tests: [FAIL]\"" >> $(KSELFTEST)
+	echo "echo \"==============================\"" >> $(KSELFTEST)
+
 run_tests:
 	@./mq_open_tests /test1 || echo "mq_open_tests: [FAIL]"
 	@./mq_perf_tests || echo "mq_perf_tests: [FAIL]"
-- 
1.9.1
