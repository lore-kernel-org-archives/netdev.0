From: josef@toxicpanda.com
Subject: [PATCH 3/3][v2] selftests: silence test output by default
Date: Tue, 19 Sep 2017 09:51:28 -0400
Message-ID: <1505829088-1823-3-git-send-email-jbacik@fb.com>
References: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
To: shuah@kernel.org, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34539 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdISNvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 09:51:33 -0400
Received: by mail-qt0-f194.google.com with SMTP id q8so2355022qtb.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 06:51:33 -0700 (PDT)
In-Reply-To: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>

Some of the networking tests are very noisy and make it impossible to
see if we actually passed the tests as they run.  Default to suppressing
the output from any tests run in order to make it easier to track what
failed.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
v1->v2:
- dump output into /tmp/testname instead of /dev/null

 tools/testing/selftests/lib.mk | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
index 693616651da5..4665463779f5 100644
--- a/tools/testing/selftests/lib.mk
+++ b/tools/testing/selftests/lib.mk
@@ -24,7 +24,7 @@ define RUN_TESTS
 			echo "selftests: Warning: file $$BASENAME_TEST is not executable, correct this.";\
 			echo "not ok 1..$$test_num selftests: $$BASENAME_TEST [FAIL]"; \
 		else					\
-			cd `dirname $$TEST` > /dev/null; (./$$BASENAME_TEST && echo "ok 1..$$test_num selftests: $$BASENAME_TEST [PASS]") || echo "not ok 1..$$test_num selftests:  $$BASENAME_TEST [FAIL]"; cd - > /dev/null;\
+			cd `dirname $$TEST` > /dev/null; (./$$BASENAME_TEST > /tmp/$$BASENAME_TEST 2>&1 && echo "ok 1..$$test_num selftests: $$BASENAME_TEST [PASS]") || echo "not ok 1..$$test_num selftests:  $$BASENAME_TEST [FAIL]"; cd - > /dev/null;\
 		fi;					\
 	done;
 endef
@@ -55,7 +55,7 @@ endif
 define EMIT_TESTS
 	@for TEST in $(TEST_GEN_PROGS) $(TEST_PROGS); do \
 		BASENAME_TEST=`basename $$TEST`;	\
-		echo "(./$$BASENAME_TEST && echo \"selftests: $$BASENAME_TEST [PASS]\") || echo \"selftests: $$BASENAME_TEST [FAIL]\""; \
+		echo "(./$$BASENAME_TEST > /tmp/$$BASENAME_TEST 2>&1 && echo \"selftests: $$BASENAME_TEST [PASS]\") || echo \"selftests: $$BASENAME_TEST [FAIL]\""; \
 	done;
 endef
 
-- 
2.7.4
