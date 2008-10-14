From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 03/14] pkt_sched: Replace explitic ->dequeue() call with
	qdisc_dequeue() in sch_multiq.
Date: Tue, 14 Oct 2008 09:53:38 +0000
Message-ID: <20081014095337.GD10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbYJNJxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:53:43 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:53:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace explitic ->dequeue() call with qdisc_dequeue() in sch_multiq.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_multiq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 915f314..df1857a 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -144,7 +144,7 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 		 */
 		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
 			qdisc = q->queues[q->curband];
-			skb = qdisc->dequeue(qdisc);
+			skb = qdisc_dequeue(qdisc);
 			if (skb) {
 				sch->q.qlen--;
 				return skb;
-- 
1.5.6.5

