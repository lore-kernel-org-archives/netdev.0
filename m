From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:15 -0700 (PDT)
Message-ID: <20080818.013715.51438108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbYHRIhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:37:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sch_hfsc: Use ->requeue queue instead of ops.

In fact this "peek head SKB for len" sequence could be
optimized even further.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_hfsc.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ea46760..bed4fd2 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -896,12 +896,7 @@ qdisc_peek_len(struct Qdisc *sch)
 		return 0;
 	}
 	len = qdisc_pkt_len(skb);
-	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
-		if (net_ratelimit())
-			printk("qdisc_peek_len: failed to requeue\n");
-		qdisc_tree_decrease_qlen(sch, 1);
-		return 0;
-	}
+	__skb_queue_head(&sch->requeue, skb);
 	return len;
 }
 
-- 
1.5.6.5.GIT

