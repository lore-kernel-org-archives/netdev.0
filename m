From: Andrea Parri <parri.andrea@gmail.com>
Subject: [PATCH RESEND] pkt_sched: sch_qfq: remove redundant -if- control statement
Date: Wed, 17 Jun 2015 00:16:59 +0200
Message-ID: <1434493019-5762-1-git-send-email-parri.andrea@gmail.com>
Cc: paolo.valente@unimore.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andrea Parri <parri.andrea@gmail.com>
To: jhs@mojatatu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The control !hlist_unhashed() in qfq_destroy_agg() is unnecessary
because already performed in hlist_del_init(), so remove it.

Signed-off-by: Andrea Parri <parri.andrea@gmail.com>
---
 net/sched/sch_qfq.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3ec7e88..b8d73bc 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -339,8 +339,7 @@ static struct qfq_aggregate *qfq_choose_next_agg(struct qfq_sched *);
 
 static void qfq_destroy_agg(struct qfq_sched *q, struct qfq_aggregate *agg)
 {
-	if (!hlist_unhashed(&agg->nonfull_next))
-		hlist_del_init(&agg->nonfull_next);
+	hlist_del_init(&agg->nonfull_next);
 	q->wsum -= agg->class_weight;
 	if (q->wsum != 0)
 		q->iwsum = ONE_FP / q->wsum;
-- 
1.9.1
