From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] sch_hhf: fix comparison of qlen and limit
Date: Fri, 9 May 2014 16:49:05 +0800
Message-ID: <1399625345-6588-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:47101 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaEIItn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 04:49:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I use the following command, eth0 cannot send any packets.
 #tc qdisc add dev eth0 root handle 1: hhf limit 1

Because qlen need be smaller than limit, all packets were dropped.
Fix this by qlen *<=* limit.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_hhf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index a9051d0fff52..9544c5caadb9 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -414,7 +414,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 		bucket->deficit = weight * q->quantum;
 	}
-	if (++sch->q.qlen < sch->limit)
+	if (++sch->q.qlen <= sch->limit)
 		return NET_XMIT_SUCCESS;
 
 	q->drop_overlimit++;
-- 
1.8.0
