From: Ferry Huberts <mailings@hupie.com>
Subject: [PATCH 1/2] net: netem: do not reorder when reordering is disabled
Date: Tue, 20 Aug 2013 17:11:08 +0200
Message-ID: <1377011469-26151-1-git-send-email-mailings@hupie.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:35333 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381Ab3HTPa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 11:30:26 -0400
Received: from stinkpad.internal.hupie.com.nl (unknown [188.205.88.52])
	by hupie.dyndns.org (Postfix) with ESMTP id 27ADA485C9D
	for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 17:11:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ferry Huberts <ferry.huberts@pelagic.nl>

The case (q->reorder == 0 && get_crandom(&q->reorder_cor) == 0)
could result in reordering even though reordering is disabled.

Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
---
 net/sched/sch_netem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 82f6016..abe5fa6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -454,7 +454,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	sch->qstats.backlog += qdisc_pkt_len(skb);
 
 	cb = netem_skb_cb(skb);
-	if (q->gap == 0 ||		/* not doing reordering */
+	if (q->gap == 0 || q->reorder == 0 || /* not doing reordering */
 	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
 		psched_time_t now;
-- 
1.8.3.1
