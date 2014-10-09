From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Skip cls-testbed.t if tests/cls dir does not exist
Date: Thu,  9 Oct 2014 18:51:24 +0300
Message-ID: <1412869884-18727-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:47649 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaJIQAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 12:00:07 -0400
Received: by mail-lb0-f174.google.com with SMTP id p9so1465100lbv.33
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 09:00:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Curently tests/cls-testbed.t tries to run any *.t in
tests/cls/ folder but such folder does not exist.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/lib/generic.sh      | 5 +++++
 testsuite/tests/cls-testbed.t | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/testsuite/lib/generic.sh b/testsuite/lib/generic.sh
index cc48947..8f76e49 100644
--- a/testsuite/lib/generic.sh
+++ b/testsuite/lib/generic.sh
@@ -21,6 +21,11 @@ ts_err_cat()
 	ts_cat "$@" | tee >> $ERRF
 }
 
+ts_skip()
+{
+    exit 127
+}
+
 ts_tc()
 {
 	SCRIPT=$1; shift
diff --git a/testsuite/tests/cls-testbed.t b/testsuite/tests/cls-testbed.t
index efae2a5..f5f9979 100755
--- a/testsuite/tests/cls-testbed.t
+++ b/testsuite/tests/cls-testbed.t
@@ -5,6 +5,11 @@ source lib/generic.sh
 
 QDISCS="cbq htb dsmark"
 
+if [ ! -d tests/cls ]; then
+    ts_log "tests/cls folder does not exist"
+    ts_skip
+fi
+
 for q in ${QDISCS}; do
 	ts_log "Preparing classifier testbed with qdisc $q"
 
-- 
2.1.0
