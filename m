From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v3 11/20] selftests/mqueue: add install target to enable test install
Date: Wed, 24 Dec 2014 09:27:47 -0700
Message-ID: <1e4aa40c42e886d36ae1bfcb93e4b8d696fa6c39.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1419387513.git.shuahkh@osg.samsung.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/mqueue/Makefile | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/mqueue/Makefile b/tools/testing/selftests/mqueue/Makefile
index 8056e2e..27757b9 100644
--- a/tools/testing/selftests/mqueue/Makefile
+++ b/tools/testing/selftests/mqueue/Makefile
@@ -1,10 +1,22 @@
+MQ_OPEN_TEST_STR = ./mq_open_tests /test1 || echo mq_open_tests: [FAIL]
+MQ_PERF_TEST_STR = ./mq_perf_tests || echo mq_perf_tests: [FAIL]
+
 all:
 	gcc -O2 mq_open_tests.c -o mq_open_tests -lrt
 	gcc -O2 -o mq_perf_tests mq_perf_tests.c -lrt -lpthread -lpopt
 
-run_tests:
-	@./mq_open_tests /test1 || echo "mq_open_tests: [FAIL]"
-	@./mq_perf_tests || echo "mq_perf_tests: [FAIL]"
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./mq_open_tests ./mq_perf_tests $(INSTALL_KSFT_PATH)
+	@echo "$(MQ_OPEN_TEST_STR)" >> $(KSELFTEST)
+	@echo "$(MQ_PERF_TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in top level source directory
+endif
+
+run_tests: all
+	@$(MQ_OPEN_TEST_STR)
+	@$(MQ_PERF_TEST_STR)
 
 clean:
 	rm -f mq_open_tests mq_perf_tests
-- 
2.1.0
