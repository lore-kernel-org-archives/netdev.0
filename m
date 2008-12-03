From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 4/3 v2] pkt_sched: sch_htb: Clean L2T()
Date: Wed, 3 Dec 2008 07:54:33 +0000
Message-ID: <20081203075433.GA7137@ff.dom.local>
References: <20081202085648.GC10412@ff.dom.local> <20081203070947.GA5598@ff.dom.local> <20081202.232522.108544572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:19479 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbYLCHyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 02:54:40 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1445345eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 23:54:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081202.232522.108544572.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 11:25:22PM -0800, David Miller wrote:
...
> Jarek, please just kill the macro and expand the calculation inline.

Hmm.. no problem... unless you think about the other macro?

Jarek P.
--------------->
pkt_sched: sch_htb: Clean L2T()

L2T() is currently used only in one place, so let's move it closer to
this place, remove unused cl parameter.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 80cb94d..4e9b8f4 100644
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
@@ -584,6 +577,12 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+static inline long L2T(struct qdisc_rate_table *rate, int size)
+{
+	long result = qdisc_l2t(rate, size);
+	return result;
+}
+
 /**
  * htb_charge_class - charges amount "bytes" to leaf and ancestors
  *
@@ -604,7 +603,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 
 #define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
 	if (toks > cl->B) toks = cl->B; \
-	toks -= L2T(cl, cl->R, bytes); \
+	toks -= L2T(cl->R, bytes); \
 	if (toks <= -cl->mbuffer) toks = 1-cl->mbuffer; \
 	cl->T = toks
 
