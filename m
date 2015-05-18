From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 02/10] tc: red, gred: Fix format specifier in burst size warning
Date: Mon, 18 May 2015 11:35:06 -0400
Message-ID: <1431963314-56420-3-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:54864 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932248AbbERPfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:34 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

burst is an unsigned value.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |    2 +-
 tc/q_red.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 625bcf9..d876f83 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -232,7 +232,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		return -1;
 	}
 	if (parm >= 10)
-		fprintf(stderr, "GRED: WARNING. Burst %d seems to be too "
+		fprintf(stderr, "GRED: WARNING. Burst %u seems to be too "
 		    "large.\n", burst);
 	opt.Wlog = parm;
 	if ((parm = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
diff --git a/tc/q_red.c b/tc/q_red.c
index 5a74c50..6555eb2 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -131,7 +131,7 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		return -1;
 	}
 	if (parm >= 10)
-		fprintf(stderr, "RED: WARNING. Burst %d seems to be too large.\n", burst);
+		fprintf(stderr, "RED: WARNING. Burst %u seems to be too large.\n", burst);
 	opt.Wlog = parm;
 	if ((parm = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
 		fprintf(stderr, "RED: failed to calculate probability.\n");
-- 
1.7.1
