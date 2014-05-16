From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] pkt_sched: return NET_XMIT_DROP when packet is dropped
Date: Fri, 16 May 2014 17:19:50 +0800
Message-ID: <1400231990-10404-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:32489 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbaEPJT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 05:19:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If packets are dropped in enqueue(), it should not return
NET_XMIT_SUCCESS but NET_XMIT_DROP.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq_codel.c | 2 +-
 net/sched/sch_hhf.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 0bf432c782c1..303ab0ce23ab 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -207,7 +207,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	/* As we dropped a packet, better let upper stack know this */
 	qdisc_tree_decrease_qlen(sch, 1);
-	return NET_XMIT_SUCCESS;
+	return NET_XMIT_DROP;
 }
 
 /* This is the specific function called from codel_dequeue()
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 6aab8619bbb0..a13d1d78ded1 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -426,7 +426,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	/* As we dropped a packet, better let upper stack know this. */
 	qdisc_tree_decrease_qlen(sch, 1);
-	return NET_XMIT_SUCCESS;
+	return NET_XMIT_DROP;
 }
 
 static struct sk_buff *hhf_dequeue(struct Qdisc *sch)
-- 
1.8.0
