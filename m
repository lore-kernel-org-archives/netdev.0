From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/10] net_sched: sch_codel: defer skb freeing in codel_change()
Date: Mon, 13 Jun 2016 20:21:52 -0700
Message-ID: <1465874519-25494-4-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34868 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:23:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id hl6so51796251pac.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:23:05 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

codel_change() can use rtnl_qdisc_drop()
to defer expensive skb freeing after locks are released.

codel_reset() already has support for deferred skb freeing
because it uses qdisc_reset_queue()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_codel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index dddf3bb65a32..c5bc424e3b3c 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -174,7 +174,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 
 		dropped += qdisc_pkt_len(skb);
 		qdisc_qstats_backlog_dec(sch, skb);
-		qdisc_drop(skb, sch);
+		rtnl_qdisc_drop(skb, sch);
 	}
 	qdisc_tree_reduce_backlog(sch, qlen - sch->q.qlen, dropped);
 
-- 
2.8.0.rc3.226.g39d4020
