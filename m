From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 5/7] Add linklayer parameter to CBQ.
Date: Wed, 9 Apr 2008 23:04:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092303550.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57375 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110AbYDIVEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:04:55 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/q_cbq.c |   18 +++++++++++++++---
  1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index e53d167..c99dc3b 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -32,7 +32,7 @@ static void explain_class(void)
  	fprintf(stderr, "               [ prio NUMBER ] [ cell BYTES ] [ ewma LOG ]\n");
  	fprintf(stderr, "               [ estimator INTERVAL TIME_CONSTANT ]\n");
  	fprintf(stderr, "               [ split CLASSID ] [ defmap MASK/CHANGE ]\n");
-	fprintf(stderr, "               [ overhead BYTES ]\n");
+	fprintf(stderr, "               [ overhead BYTES ] [ linklayer TYPE ]\n");
  }

  static void explain(void)
@@ -55,6 +55,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
  	__u32 rtab[256];
  	unsigned mpu=0, avpkt=0, allot=0;
  	unsigned short overhead=0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
  	int cell_log=-1;
  	int ewma_log=-1;
  	struct rtattr *tail;
@@ -120,6 +121,11 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
  			if (get_u16(&overhead, *argv, 10)) {
  				explain1("overhead"); return -1;
  			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer"); return -1;
+			}
  		} else if (matches(*argv, "help") == 0) {
  			explain();
  			return -1;
@@ -146,7 +152,7 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl

  	r.mpu = mpu;
  	r.overhead = overhead;
-	if (tc_calc_rtable(&r, rtab, cell_log, allot) < 0) {
+	if (tc_calc_rtable(&r, rtab, cell_log, allot, linklayer) < 0) {
  		fprintf(stderr, "CBQ: failed to calculate rate table.\n");
  		return -1;
  	}
@@ -188,6 +194,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  	unsigned bndw = 0;
  	unsigned minburst=0, maxburst=0;
  	unsigned short overhead=0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
  	struct rtattr *tail;

  	memset(&r, 0, sizeof(r));
@@ -331,6 +338,11 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  			if (get_u16(&overhead, *argv, 10)) {
  				explain1("overhead"); return -1;
  			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer"); return -1;
+			}
  		} else if (matches(*argv, "help") == 0) {
  			explain_class();
  			return -1;
@@ -351,7 +363,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
  			wrr.allot = (lss.avpkt*3)/2;
  		r.mpu = mpu;
  		r.overhead = overhead;
-		if (tc_calc_rtable(&r, rtab, cell_log, pktsize) < 0) {
+		if (tc_calc_rtable(&r, rtab, cell_log, pktsize, linklayer) < 0) {
  			fprintf(stderr, "CBQ: failed to calculate rate table.\n");
  			return -1;
  		}
-- 
1.5.3

