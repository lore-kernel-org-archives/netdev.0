From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 03/10] tc: red, gred: Notify when using the default value for "bandwidth"
Date: Mon, 18 May 2015 11:35:07 -0400
Message-ID: <1431963314-56420-4-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-2.mit.edu ([18.9.25.13]:48541 "EHLO
	dmz-mailsec-scanner-2.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbbERPfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:40 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "bandwidth" parameter is optional, but ensure the user is aware
of its default value, to proactively avoid configuration problems.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |    7 ++++---
 tc/q_red.c  |    7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index d876f83..5e0dfcf 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -214,9 +214,6 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		argc--; argv++;
 	}
 
-	if (rate == 0)
-		get_rate(&rate, "10Mbit");
-
 	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt ||
 	    (opt.DP<0)) {
 		fprintf(stderr, "Required parameter (min, max, limit, "
@@ -227,6 +224,10 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
 		fprintf(stderr, "GRED: set burst to %u\n", burst);
 	}
+	if (!rate) {
+		get_rate(&rate, "10Mbit");
+		fprintf(stderr, "GRED: set bandwidth to 10Mbit\n");
+	}
 	if ((parm = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "GRED: failed to calculate EWMA constant.\n");
 		return -1;
diff --git a/tc/q_red.c b/tc/q_red.c
index 6555eb2..1bf2bd9 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -109,9 +109,6 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		argc--; argv++;
 	}
 
-	if (rate == 0)
-		get_rate(&rate, "10Mbit");
-
 	if (!opt.limit || !avpkt) {
 		fprintf(stderr, "RED: Required parameter (limit, avpkt) is missing\n");
 		return -1;
@@ -126,6 +123,10 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		opt.qth_min = opt.qth_max / 3;
 	if (!burst)
 		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
+	if (!rate) {
+		get_rate(&rate, "10Mbit");
+		fprintf(stderr, "RED: set bandwidth to 10Mbit\n");
+	}
 	if ((parm = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "RED: failed to calculate EWMA constant.\n");
 		return -1;
-- 
1.7.1
