From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/10] net_sched: sch_pie: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:58 -0700
Message-ID: <1465874519-25494-10-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33227 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423760AbcFNDYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:24:07 -0400
Received: by mail-pf0-f174.google.com with SMTP id y124so52573539pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:24:06 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pie_change() can use rtnl_qdisc_drop() to benefit from
deferred freeing.

pie_reset() is already using qdisc_reset_queue()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_pie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index 71ae3b9629f9..912a46a5d02e 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -234,7 +234,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 
 		dropped += qdisc_pkt_len(skb);
 		qdisc_qstats_backlog_dec(sch, skb);
-		qdisc_drop(skb, sch);
+		rtnl_qdisc_drop(skb, sch);
 	}
 	qdisc_tree_reduce_backlog(sch, qlen - sch->q.qlen, dropped);
 
-- 
2.8.0.rc3.226.g39d4020
