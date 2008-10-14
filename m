From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 07/14] sch_hfsc: Use ->requeue queue instead of ops.
Date: Tue, 14 Oct 2008 09:54:23 +0000
Message-ID: <20081014095423.GH10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbYJNJy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:54:28 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:54:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Mon, 18 Aug 2008 01:37:15 -0700 (PDT)
From: David Miller <davem@davemloft.net>

------------------>
From: David Miller <davem@davemloft.net>
sch_hfsc: Use ->requeue queue instead of ops.

In fact this "peek head SKB for len" sequence could be
optimized even further.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_hfsc.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 67aa3ea..87da751 100644
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
1.5.6.5

