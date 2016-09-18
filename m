From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_qfq: keep backlog updated with qlen
Date: Sun, 18 Sep 2016 16:22:47 -0700
Message-ID: <1474240968-15202-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33655 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755333AbcIRXWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 19:22:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id q2so3666482pfj.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 16:22:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_qfq.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index f27ffee..ca0516e 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1153,6 +1153,7 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 	if (!skb)
 		return NULL;
 
+	qdisc_qstats_backlog_dec(sch, skb);
 	sch->q.qlen--;
 	qdisc_bstats_update(sch, skb);
 
@@ -1256,6 +1257,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	bstats_update(&cl->bstats, skb);
+	qdisc_qstats_backlog_inc(sch, skb);
 	++sch->q.qlen;
 
 	agg = cl->agg;
@@ -1476,6 +1478,7 @@ static void qfq_reset_qdisc(struct Qdisc *sch)
 			qdisc_reset(cl->qdisc);
 		}
 	}
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 }
 
-- 
2.1.0
