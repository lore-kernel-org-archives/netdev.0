From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] net/sched: fq_codel: Avoid set-but-unused variable
Date: Thu, 16 Mar 2017 10:49:05 +0200
Message-ID: <1489654145-20532-3-git-send-email-ogerlitz@mellanox.com>
References: <1489654145-20532-1-git-send-email-ogerlitz@mellanox.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52398 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751118AbdCPItQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:49:16 -0400
In-Reply-To: <1489654145-20532-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code introduced by commit 2ccccf5fb "net_sched: update hierarchical
backlog too" only sets prev_backlog in fq_codel_dequeue() but not
using that anywhere, remove that setting.

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/sch_fq_codel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 9f3a884..097bbe9 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -288,7 +288,6 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 	struct fq_codel_flow *flow;
 	struct list_head *head;
 	u32 prev_drop_count, prev_ecn_mark;
-	unsigned int prev_backlog;
 
 begin:
 	head = &q->new_flows;
@@ -307,7 +306,6 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 
 	prev_drop_count = q->cstats.drop_count;
 	prev_ecn_mark = q->cstats.ecn_mark;
-	prev_backlog = sch->qstats.backlog;
 
 	skb = codel_dequeue(sch, &sch->qstats.backlog, &q->cparams,
 			    &flow->cvars, &q->cstats, qdisc_pkt_len,
-- 
2.3.7
