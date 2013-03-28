From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Thu, 28 Mar 2013 16:52:00 -0700
Message-ID: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:50297 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab3C1XxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 19:53:14 -0400
Received: by mail-da0-f41.google.com with SMTP id w4so26296dam.28
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 16:53:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we hold a max of sch->limit -1 number of packets instead of
sch->limit packets. Fix this off-by-one error.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/sched/sch_fq_codel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 4e606fc..5578628 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -195,7 +195,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		flow->deficit = q->quantum;
 		flow->dropped = 0;
 	}
-	if (++sch->q.qlen < sch->limit)
+	if (++sch->q.qlen <= sch->limit)
 		return NET_XMIT_SUCCESS;
 
 	q->drop_overlimit++;
-- 
1.7.9.5
