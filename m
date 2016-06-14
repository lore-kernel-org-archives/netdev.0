From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/10] net_sched: sch_hhf: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:55 -0700
Message-ID: <1465874519-25494-7-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32941 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:23:40 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so29421316pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:23:40 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both hhf_reset() and hhf_change() can use rtnl_kfree_skbs()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_hhf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index c51791848a38..c44593b8e65a 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -464,7 +464,7 @@ static void hhf_reset(struct Qdisc *sch)
 	struct sk_buff *skb;
 
 	while ((skb = hhf_dequeue(sch)) != NULL)
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 }
 
 static void *hhf_zalloc(size_t sz)
@@ -574,7 +574,7 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = hhf_dequeue(sch);
 
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 	}
 	qdisc_tree_reduce_backlog(sch, qlen - sch->q.qlen,
 				  prev_backlog - sch->qstats.backlog);
-- 
2.8.0.rc3.226.g39d4020
