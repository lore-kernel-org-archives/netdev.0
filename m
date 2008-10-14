From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 05/14] sch_tbf: Use ->requeue queue instead of ops.
Date: Tue, 14 Oct 2008 09:54:02 +0000
Message-ID: <20081014095402.GF10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754925AbYJNJyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:54:08 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:54:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 6/9]: sch_tbf: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:08 -0700 (PDT)
From: David Miller <davem@davemloft.net>

--------------------->
From: David Miller <davem@davemloft.net>
sch_tbf: Use ->requeue queue instead of ops.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
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
1.5.6.5

