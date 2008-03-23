From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/5] [IPROUTE2] Change CBQ to use matches() function
	instead of strcmp().
Date: Mon, 24 Mar 2008 00:44:14 +0100
Message-ID: <1206315854.15884.53.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48905 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757034AbYCWXpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change CBQ to use matches() function instead of strcmp().

This resembels the usage in other parse functions, and allows
partial command parameter matching.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 tc/q_cbq.c |   54 +++++++++++++++++++++++++++---------------------------
 1 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index df98312..8e6bd40 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -61,14 +61,14 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	memset(&r, 0, sizeof(r));
 
 	while (argc > 0) {
-		if (strcmp(*argv, "bandwidth") == 0 ||
-		    strcmp(*argv, "rate") == 0) {
+		if (matches(*argv, "bandwidth") == 0 ||
+		    matches(*argv, "rate") == 0) {
 			NEXT_ARG();
 			if (get_rate(&r.rate, *argv)) {
 				explain1("bandwidth");
 				return -1;
 			}
-		} else if (strcmp(*argv, "ewma") == 0) {
+		} else if (matches(*argv, "ewma") == 0) {
 			NEXT_ARG();
 			if (get_integer(&ewma_log, *argv, 0)) {
 				explain1("ewma");
@@ -78,7 +78,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				fprintf(stderr, "ewma_log must be < 32\n");
 				return -1;
 			}
-		} else if (strcmp(*argv, "cell") == 0) {
+		} else if (matches(*argv, "cell") == 0) {
 			unsigned cell;
 			int i;
 			NEXT_ARG();
@@ -94,26 +94,26 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 				return -1;
 			}
 			cell_log = i;
-		} else if (strcmp(*argv, "avpkt") == 0) {
+		} else if (matches(*argv, "avpkt") == 0) {
 			NEXT_ARG();
 			if (get_size(&avpkt, *argv)) {
 				explain1("avpkt");
 				return -1;
 			}
-		} else if (strcmp(*argv, "mpu") == 0) {
+		} else if (matches(*argv, "mpu") == 0) {
 			NEXT_ARG();
 			if (get_size(&mpu, *argv)) {
 				explain1("mpu");
 				return -1;
 			}
-		} else if (strcmp(*argv, "allot") == 0) {
+		} else if (matches(*argv, "allot") == 0) {
 			NEXT_ARG();
 			/* Accept and ignore "allot" for backward compatibility */
 			if (get_size(&allot, *argv)) {
 				explain1("allot");
 				return -1;
 			}
-		} else if (strcmp(*argv, "help") == 0) {
+		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
 		} else {
@@ -188,52 +188,52 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	memset(&ovl, 0, sizeof(ovl));
 
 	while (argc > 0) {
-		if (strcmp(*argv, "rate") == 0) {
+		if (matches(*argv, "rate") == 0) {
 			NEXT_ARG();
 			if (get_rate(&r.rate, *argv)) {
 				explain1("rate");
 				return -1;
 			}
-		} else if (strcmp(*argv, "bandwidth") == 0) {
+		} else if (matches(*argv, "bandwidth") == 0) {
 			NEXT_ARG();
 			if (get_rate(&bndw, *argv)) {
 				explain1("bandwidth");
 				return -1;
 			}
-		} else if (strcmp(*argv, "minidle") == 0) {
+		} else if (matches(*argv, "minidle") == 0) {
 			NEXT_ARG();
 			if (get_u32(&lss.minidle, *argv, 0)) {
 				explain1("minidle");
 				return -1;
 			}
 			lss.change |= TCF_CBQ_LSS_MINIDLE;
-		} else if (strcmp(*argv, "minburst") == 0) {
+		} else if (matches(*argv, "minburst") == 0) {
 			NEXT_ARG();
 			if (get_u32(&minburst, *argv, 0)) {
 				explain1("minburst");
 				return -1;
 			}
 			lss.change |= TCF_CBQ_LSS_OFFTIME;
-		} else if (strcmp(*argv, "maxburst") == 0) {
+		} else if (matches(*argv, "maxburst") == 0) {
 			NEXT_ARG();
 			if (get_u32(&maxburst, *argv, 0)) {
 				explain1("maxburst");
 				return -1;
 			}
 			lss.change |= TCF_CBQ_LSS_MAXIDLE;
-		} else if (strcmp(*argv, "bounded") == 0) {
+		} else if (matches(*argv, "bounded") == 0) {
 			lss.flags |= TCF_CBQ_LSS_BOUNDED;
 			lss.change |= TCF_CBQ_LSS_FLAGS;
-		} else if (strcmp(*argv, "borrow") == 0) {
+		} else if (matches(*argv, "borrow") == 0) {
 			lss.flags &= ~TCF_CBQ_LSS_BOUNDED;
 			lss.change |= TCF_CBQ_LSS_FLAGS;
-		} else if (strcmp(*argv, "isolated") == 0) {
+		} else if (matches(*argv, "isolated") == 0) {
 			lss.flags |= TCF_CBQ_LSS_ISOLATED;
 			lss.change |= TCF_CBQ_LSS_FLAGS;
-		} else if (strcmp(*argv, "sharing") == 0) {
+		} else if (matches(*argv, "sharing") == 0) {
 			lss.flags &= ~TCF_CBQ_LSS_ISOLATED;
 			lss.change |= TCF_CBQ_LSS_FLAGS;
-		} else if (strcmp(*argv, "ewma") == 0) {
+		} else if (matches(*argv, "ewma") == 0) {
 			NEXT_ARG();
 			if (get_integer(&ewma_log, *argv, 0)) {
 				explain1("ewma");
@@ -244,7 +244,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 				return -1;
 			}
 			lss.change |= TCF_CBQ_LSS_EWMA;
-		} else if (strcmp(*argv, "cell") == 0) {
+		} else if (matches(*argv, "cell") == 0) {
 			unsigned cell;
 			int i;
 			NEXT_ARG();
@@ -260,7 +260,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 				return -1;
 			}
 			cell_log = i;
-		} else if (strcmp(*argv, "prio") == 0) {
+		} else if (matches(*argv, "prio") == 0) {
 			unsigned prio;
 			NEXT_ARG();
 			if (get_u32(&prio, *argv, 0)) {
@@ -273,40 +273,40 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			}
 			wrr.priority = prio;
 			wrr_ok++;
-		} else if (strcmp(*argv, "allot") == 0) {
+		} else if (matches(*argv, "allot") == 0) {
 			NEXT_ARG();
 			if (get_size(&wrr.allot, *argv)) {
 				explain1("allot");
 				return -1;
 			}
-		} else if (strcmp(*argv, "avpkt") == 0) {
+		} else if (matches(*argv, "avpkt") == 0) {
 			NEXT_ARG();
 			if (get_size(&lss.avpkt, *argv)) {
 				explain1("avpkt");
 				return -1;
 			}
 			lss.change |= TCF_CBQ_LSS_AVPKT;
-		} else if (strcmp(*argv, "mpu") == 0) {
+		} else if (matches(*argv, "mpu") == 0) {
 			NEXT_ARG();
 			if (get_size(&mpu, *argv)) {
 				explain1("mpu");
 				return -1;
 			}
-		} else if (strcmp(*argv, "weight") == 0) {
+		} else if (matches(*argv, "weight") == 0) {
 			NEXT_ARG();
 			if (get_size(&wrr.weight, *argv)) {
 				explain1("weight");
 				return -1;
 			}
 			wrr_ok++;
-		} else if (strcmp(*argv, "split") == 0) {
+		} else if (matches(*argv, "split") == 0) {
 			NEXT_ARG();
 			if (get_tc_classid(&fopt.split, *argv)) {
 				fprintf(stderr, "Invalid split node ID.\n");
 				usage();
 			}
 			fopt_ok++;
-		} else if (strcmp(*argv, "defmap") == 0) {
+		} else if (matches(*argv, "defmap") == 0) {
 			int err;
 			NEXT_ARG();
 			err = sscanf(*argv, "%08x/%08x", &fopt.defmap, &fopt.defchange);
@@ -317,7 +317,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			if (err == 1)
 				fopt.defchange = ~0;
 			fopt_ok++;
-		} else if (strcmp(*argv, "help") == 0) {
+		} else if (matches(*argv, "help") == 0) {
 			explain_class();
 			return -1;
 		} else {
-- 
1.5.3


