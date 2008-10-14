From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 06/14] sch_atm: Use ->requeue queue instead of ops.
Date: Tue, 14 Oct 2008 09:54:12 +0000
Message-ID: <20081014095412.GG10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980AbYJNJyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:54:18 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:54:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 7/9]: sch_atm: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:12 -0700 (PDT)
From: David Miller <davem@davemloft.net>

------------------->
From: David Miller <davem@davemloft.net>
sch_atm: Use ->requeue queue instead of ops.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
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
1.5.6.5

