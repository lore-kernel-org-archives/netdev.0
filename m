From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net_sched: use setup_deferrable_timer
Date: Fri, 24 Mar 2017 22:14:36 +0800
Message-ID: <8333b4c5b4aef4b847b1132d52c214764c41ebe5.1490340639.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use setup_deferrable_timer() instead of init_timer_deferrable() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/sched/cls_flow.c | 5 ++---
 net/sched/sch_sfq.c  | 5 ++---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 3d6b928..ca193af 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -508,9 +508,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		get_random_bytes(&fnew->hashrnd, 4);
 	}
 
-	fnew->perturb_timer.function = flow_perturbation;
-	fnew->perturb_timer.data = (unsigned long)fnew;
-	init_timer_deferrable(&fnew->perturb_timer);
+	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
+			       (unsigned long)fnew);
 
 	tcf_exts_change(tp, &fnew->exts, &e);
 	tcf_em_tree_change(tp, &fnew->ematches, &t);
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 9b0911c..332d94b 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -710,9 +710,8 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
 
-	q->perturb_timer.function = sfq_perturbation;
-	q->perturb_timer.data = (unsigned long)sch;
-	init_timer_deferrable(&q->perturb_timer);
+	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
+			       (unsigned long)sch);
 
 	for (i = 0; i < SFQ_MAX_DEPTH + 1; i++) {
 		q->dep[i].next = i + SFQ_MAX_FLOWS;
-- 
2.9.3
