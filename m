From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 4/3 v3] pkt_sched: sch_htb: Clean L2T()
Date: Wed, 3 Dec 2008 08:50:06 +0000
Message-ID: <20081203085006.GA15262@ff.dom.local>
References: <20081203070947.GA5598@ff.dom.local> <20081202.232522.108544572.davem@davemloft.net> <20081203075433.GA7137@ff.dom.local> <20081203.002046.153795689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:40496 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbYLCIuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 03:50:13 -0500
Received: by ug-out-1314.google.com with SMTP id 39so3323430ugf.37
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 00:50:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081203.002046.153795689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2008 at 12:20:46AM -0800, David Miller wrote:
...
> You misunderstood me.
> 
> I meant get rid of L2T completely, and just use
> "qdisc_l2t(rate, size)" directly.
> 
> Macros like this one:
> 
> 1) are used in only one spot
> 2) give no new information to the reader
> 
> so are just extra noise.

Hmm.. I think L2T is special in sched, but no problem...

Thanks for the explanation,
Jarek P.
------------------> (take 3)
pkt_sched: sch_htb: Remove L2T()

L2T() is currently used only in one place (and has one spurious
parameter, btw), so let's: 'get rid of L2T completely, and just
use "qdisc_l2t(rate, size)" directly.' - quote & feedback from
David S. Miller.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 80cb94d..fcd06e2 100644
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
@@ -604,7 +597,7 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 
 #define HTB_ACCNT(T,B,R) toks = diff + cl->T; \
 	if (toks > cl->B) toks = cl->B; \
-	toks -= L2T(cl, cl->R, bytes); \
+	toks -= (long) qdisc_l2t(cl->R, bytes); \
 	if (toks <= -cl->mbuffer) toks = 1-cl->mbuffer; \
 	cl->T = toks
 
