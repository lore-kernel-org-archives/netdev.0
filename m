From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/9]: sch_tbf: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:08 -0700 (PDT)
Message-ID: <20080818.013708.175993535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751074AbYHRIhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sch_tbf: Use ->requeue queue instead of ops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_tbf.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a99529d..e98aeb9 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -214,12 +214,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		   (cf. CSZ, HPFQ, HFSC)
 		 */
 
-		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-			/* When requeue fails skb is dropped */
-			qdisc_tree_decrease_qlen(q->qdisc, 1);
-			sch->qstats.drops++;
-		}
-
+		__skb_queue_tail(&q->qdisc->requeue, skb);
 		sch->qstats.overlimits++;
 	}
 	return NULL;
-- 
1.5.6.5.GIT

