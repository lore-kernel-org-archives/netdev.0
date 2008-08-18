From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/9]: sch_atm: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:12 -0700 (PDT)
Message-ID: <20080818.013712.103411885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbYHRIhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:37:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sch_atm: Use ->requeue queue instead of ops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_atm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index ca3467b..c8bc5fc 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -482,7 +482,7 @@ static void sch_atm_dequeue(unsigned long data)
 		 */
 		while ((skb = qdisc_dequeue(flow->q))) {
 			if (!atm_may_send(flow->vcc, skb->truesize)) {
-				(void)flow->q->ops->requeue(skb, flow->q);
+				__skb_queue_tail(&flow->q->requeue, skb);
 				break;
 			}
 			pr_debug("atm_tc_dequeue: sending on class %p\n", flow);
-- 
1.5.6.5.GIT

