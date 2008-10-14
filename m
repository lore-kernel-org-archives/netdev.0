From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 01/14] pkt_sched: Add qdisc_dequeue() helper.
Date: Tue, 14 Oct 2008 09:53:09 +0000
Message-ID: <20081014095308.GB10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbYJNJxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:53:13 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:53:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 3/9]: pkt_sched: Add qdisc_dequeue() helper.
Date: Mon, 18 Aug 2008 01:36:55 -0700 (PDT)
From: David Miller <davem@davemloft.net>

Modified sch_generic.c part.

------------->
From: David Miller <davem@davemloft.net>
pkt_sched: Add qdisc_dequeue() helper.

It prioritizes packets on the ->requeue list.

Use in qdisc_restart() as it's basically a complete
copy of dequeue_skb().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |    8 ++++++++
 net/sched/sch_generic.c   |    2 +-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3fe49d8..00c1309 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -369,6 +369,14 @@ enum net_xmit_qdisc_t {
 #define net_xmit_drop_count(e)	(1)
 #endif
 
+static inline struct sk_buff *qdisc_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = __skb_dequeue(&sch->requeue);
+	if (!skb)
+		skb = sch->dequeue(sch);
+	return skb;
+}
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7b5572d..6730bac 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -66,7 +66,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 		else
 			skb = NULL;
 	} else {
-		skb = q->dequeue(q);
+		skb = qdisc_dequeue(q);
 	}
 
 	return skb;
-- 
1.5.6.5

To: 
Cc: 
Bcc: 
Subject: 
Reply-To: 

