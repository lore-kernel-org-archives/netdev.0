From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 05/20] selftests/ftrace: add install target to enable test install
Date: Tue,  6 Jan 2015 12:43:19 -0700
Message-ID: <20a71af8dcebf0369890391e8587afc5ca1a8035.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	masami.hiramatsu.pt@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-04v.sys.comcast.net ([69.252.207.36]:52000 "EHLO
	resqmta-ch2-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932913AbbAFTwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:52:04 -0500
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1420571615.git.shuahkh@osg.samsung.com>
References: <cover.1420571615.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new make target to enable installing test. This target
installs test in the kselftest install location and add to the
kselftest script to run the test. Install target can be run
only from top level kernel source directory.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Acked-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
---
 tools/testing/selftests/ftrace/Makefile | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/ftrace/Makefile b/tools/testing/selftests/ftrace/Makefile
index 76cc9f1..c5c77584 100644
--- a/tools/testing/selftests/ftrace/Makefile
+++ b/tools/testing/selftests/ftrace/Makefile
@@ -1,7 +1,18 @@
+TEST_STR = /bin/sh ./ftracetest || echo 'ftrace selftests: [FAIL]'
+
 all:
 
+install:
+ifdef INSTALL_KSFT_PATH
+	install ./ftracetest $(INSTALL_KSFT_PATH)
+	@cp -r test.d $(INSTALL_KSFT_PATH)
+	echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo "Run make kselftest_install in top level source directory"
+endif
+
 run_tests:
-	@/bin/sh ./ftracetest || echo "ftrace selftests: [FAIL]"
+	@$(TEST_STR)
 
 clean:
 	rm -rf logs/*
-- 
2.1.0
