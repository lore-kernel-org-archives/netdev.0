From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/9]: pkt_sched: Always use q->requeue in dev_requeue_skb().
Date: Mon, 18 Aug 2008 01:36:50 -0700 (PDT)
Message-ID: <20080818.013650.211840097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751418AbYHRIgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:36:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Always use q->requeue in dev_requeue_skb().

There is no reason to call into the complicated qdiscs
just to remember the last SKB where we found the device
blocked.

The SKB is outside of the qdiscs realm at this point.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_generic.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 39d969e..96d7d08 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,10 +44,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	if (unlikely(skb->next))
-		__skb_queue_head(&q->requeue, skb);
-	else
-		q->ops->requeue(skb, q);
+	__skb_queue_head(&q->requeue, skb);
 
 	__netif_schedule(q);
 	return 0;
-- 
1.5.6.5.GIT

