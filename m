From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/7] fq_codel: fix set never used warning
Date: Tue, 10 Jan 2017 10:18:16 -0800
Message-ID: <20170110181816.18991-8-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34186 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939984AbdAJSSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:32 -0500
Received: by mail-pf0-f182.google.com with SMTP id 127so50804721pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:32 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prev_backlog was set in fq_codel_dequeue but never used.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/sched/sch_fq_codel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index a5ea0e9b6be4..6709c62123ad 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -290,7 +290,6 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 	struct fq_codel_flow *flow;
 	struct list_head *head;
 	u32 prev_drop_count, prev_ecn_mark;
-	unsigned int prev_backlog;
 
 begin:
 	head = &q->new_flows;
@@ -309,7 +308,6 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 
 	prev_drop_count = q->cstats.drop_count;
 	prev_ecn_mark = q->cstats.ecn_mark;
-	prev_backlog = sch->qstats.backlog;
 
 	skb = codel_dequeue(sch, &sch->qstats.backlog, &q->cparams,
 			    &flow->cvars, &q->cstats, qdisc_pkt_len,
-- 
2.11.0
