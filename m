From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Dont fail cls-testbed.t if tests/cls dir is empty
Date: Tue, 30 Sep 2014 01:57:16 +0300
Message-ID: <1412031436-14492-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:48221 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbaI2XFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 19:05:47 -0400
Received: by mail-la0-f48.google.com with SMTP id q1so7343354lam.21
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 16:05:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Curently tests/cls-testbed.t tries to run any *.t in
tests/cls/ folder but such folder does not exist.

The better solution can be like having a generic mechanism which
allows to SKIP some tests (by return code?).

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/tests/cls-testbed.t | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/testsuite/tests/cls-testbed.t b/testsuite/tests/cls-testbed.t
index efae2a5..be32d79 100755
--- a/testsuite/tests/cls-testbed.t
+++ b/testsuite/tests/cls-testbed.t
@@ -5,6 +5,11 @@ source lib/generic.sh
 
 QDISCS="cbq htb dsmark"
 
+if [ ! -d tests/cls ]; then
+    ts_log "tests/cls folder is empty"
+    exit 0
+fi
+
 for q in ${QDISCS}; do
 	ts_log "Preparing classifier testbed with qdisc $q"
 
-- 
2.1.0
