From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 01/10] tc: red, gred: Rename overloaded variable wlog
Date: Mon, 18 May 2015 11:35:05 -0400
Message-ID: <1431963314-56420-2-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-3.mit.edu ([18.9.25.14]:58893 "EHLO
	dmz-mailsec-scanner-3.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932247AbbERPfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:32 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is used when parsing three different parameters, only one of
which is Wlog. Change the name to make the code less confusing.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |   17 ++++++++---------
 tc/q_red.c  |   16 ++++++++--------
 2 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 88bd094..625bcf9 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -123,7 +123,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	unsigned avpkt = 0;
 	double probability = 0.02;
 	unsigned rate = 0;
-	int wlog;
+	int parm;
 	__u8 sbuf[256];
 	struct rtattr *tail;
 	__u32 max_P;
@@ -227,27 +227,26 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
 		fprintf(stderr, "GRED: set burst to %u\n", burst);
 	}
-
-	if ((wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
+	if ((parm = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "GRED: failed to calculate EWMA constant.\n");
 		return -1;
 	}
-	if (wlog >= 10)
+	if (parm >= 10)
 		fprintf(stderr, "GRED: WARNING. Burst %d seems to be too "
 		    "large.\n", burst);
-	opt.Wlog = wlog;
-	if ((wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
+	opt.Wlog = parm;
+	if ((parm = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
 		fprintf(stderr, "GRED: failed to calculate probability.\n");
 		return -1;
 	}
-	opt.Plog = wlog;
-	if ((wlog = tc_red_eval_idle_damping(opt.Wlog, avpkt, rate, sbuf)) < 0)
+	opt.Plog = parm;
+	if ((parm = tc_red_eval_idle_damping(opt.Wlog, avpkt, rate, sbuf)) < 0)
 	    {
 		fprintf(stderr, "GRED: failed to calculate idle damping "
 		    "table.\n");
 		return -1;
 	}
-	opt.Scell_log = wlog;
+	opt.Scell_log = parm;
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
diff --git a/tc/q_red.c b/tc/q_red.c
index 89e7320..5a74c50 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -40,7 +40,7 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	unsigned avpkt = 0;
 	double probability = 0.02;
 	unsigned rate = 0;
-	int wlog;
+	int parm;
 	__u8 sbuf[256];
 	__u32 max_P;
 	struct rtattr *tail;
@@ -126,23 +126,23 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 		opt.qth_min = opt.qth_max / 3;
 	if (!burst)
 		burst = (2 * opt.qth_min + opt.qth_max) / (3 * avpkt);
-	if ((wlog = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
+	if ((parm = tc_red_eval_ewma(opt.qth_min, burst, avpkt)) < 0) {
 		fprintf(stderr, "RED: failed to calculate EWMA constant.\n");
 		return -1;
 	}
-	if (wlog >= 10)
+	if (parm >= 10)
 		fprintf(stderr, "RED: WARNING. Burst %d seems to be too large.\n", burst);
-	opt.Wlog = wlog;
-	if ((wlog = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
+	opt.Wlog = parm;
+	if ((parm = tc_red_eval_P(opt.qth_min, opt.qth_max, probability)) < 0) {
 		fprintf(stderr, "RED: failed to calculate probability.\n");
 		return -1;
 	}
-	opt.Plog = wlog;
-	if ((wlog = tc_red_eval_idle_damping(opt.Wlog, avpkt, rate, sbuf)) < 0) {
+	opt.Plog = parm;
+	if ((parm = tc_red_eval_idle_damping(opt.Wlog, avpkt, rate, sbuf)) < 0) {
 		fprintf(stderr, "RED: failed to calculate idle damping table.\n");
 		return -1;
 	}
-	opt.Scell_log = wlog;
+	opt.Scell_log = parm;
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
-- 
1.7.1
