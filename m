From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 4/3] pkt_sched: sch_htb: Clean L2T()
Date: Wed, 3 Dec 2008 07:09:47 +0000
Message-ID: <20081203070947.GA5598@ff.dom.local>
References: <20081202085648.GC10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:63350 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbYLCHJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 02:09:54 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1774891nfc.21
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 23:09:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081202085648.GC10412@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2T() is currently used only in one place, so let's move it closer to
this place, remove unused cl parameter, and change to a macro.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 80cb94d..78f20d6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -125,13 +125,6 @@ struct htb_class {
 	psched_time_t t_c;	/* checkpoint time */
 };
 
-static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
-			   int size)
-{
-	long result = qdisc_l2t(rate, size);
-	return result;
-}
-
 struct htb_sched {
 	struct Qdisc_class_hash clhash;
 	struct list_head drops[TC_HTB_NUMPRIO];/* active leaves (for drops) */
@@ -602,9 +595,11 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 	long toks, diff;
 	enum htb_cmode old_mode;
 
+#define L2T(rate, size)	((long) qdisc_l2t(rate, size))
+
 #define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
 	if (toks > cl->B) toks = cl->B; \
-	toks -= L2T(cl, cl->R, bytes); \
+	toks -= L2T(cl->R, bytes); \
 	if (toks <= -cl->mbuffer) toks = 1-cl->mbuffer; \
 	cl->T = toks
 
