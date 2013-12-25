From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/2] sch_netem: more precise length of packets
Date: Wed, 25 Dec 2013 17:35:14 +0800
Message-ID: <1387964115-31168-2-git-send-email-yangyingliang@huawei.com>
References: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:27965 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3LYJfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 04:35:25 -0500
In-Reply-To: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With TSO/GSO/GRO packets, skb->len doesn't represent
a precise amount of bytes on wire.
This patch replace skb->len with qdisc_pkt_len(skb)
which is more precise.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f3befd6..9632a4e 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -495,7 +495,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				now = netem_skb_cb(last)->time_to_send;
 			}
 
-			delay += packet_len_2_sched_time(skb->len, q);
+			delay += packet_len_2_sched_time(qdisc_pkt_len(skb), q);
 		}
 
 		cb->time_to_send = now + delay;
-- 
1.8.0
