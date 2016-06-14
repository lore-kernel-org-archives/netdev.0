From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/10] net_sched: sch_fq: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:59 -0700
Message-ID: <1465874519-25494-11-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33235 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423760AbcFNDYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:24:10 -0400
Received: by mail-pf0-f173.google.com with SMTP id y124so52573980pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:24:10 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sfq_reset() can use rtnl_kfree_skbs() instead of kfree_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_sfq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a2e0b855d1c8..57d118b41cad 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -520,7 +520,7 @@ sfq_reset(struct Qdisc *sch)
 	struct sk_buff *skb;
 
 	while ((skb = sfq_dequeue(sch)) != NULL)
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 }
 
 /*
-- 
2.8.0.rc3.226.g39d4020
