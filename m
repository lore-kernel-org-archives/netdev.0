From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/3] pkt_sched: sch_htb: Remove htb_sched nwc_hit field
Date: Tue, 2 Dec 2008 08:56:36 +0000
Message-ID: <20081202085636.GB10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:23651 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbYLBI4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:56:42 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1228579eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 00:56:40 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove practically unused struct htb_sched nwc_hit field.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index ce8b1ad..7a71e94 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -151,9 +151,6 @@ struct htb_sched {
 	/* time of nearest event per level (row) */
 	psched_time_t near_ev_cache[TC_HTB_MAXDEPTH];
 
-	/* whether we hit non-work conserving class during this dequeue; we use */
-	int nwc_hit;		/* this to disable mindelay complaint in dequeue */
-
 	int defcls;		/* class where unclassified flows go to */
 
 	/* filters for qdisc itself */
@@ -807,7 +804,7 @@ next:
 			       cl->common.classid);
 			cl->warned = 1;
 		}
-		q->nwc_hit++;
+
 		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
 				  ptr[0]) + prio);
 		cl = htb_lookup_leaf(q->row[level] + prio, prio,
@@ -852,7 +849,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	q->now = psched_get_time();
 
 	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
-	q->nwc_hit = 0;
+
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
 		int m;
-- 
1.5.6.5

