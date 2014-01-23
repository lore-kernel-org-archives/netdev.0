From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/3] sch_netem: change some func's param from "struct Qdisc *" to "struct netem_sched_data *"
Date: Thu, 23 Jan 2014 17:31:38 +0800
Message-ID: <1390469499-31952-3-git-send-email-yangyingliang@huawei.com>
References: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4333 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaAWJcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:32:33 -0500
In-Reply-To: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netem_change(), we have already get "struct netem_sched_data *q".
Replace params of get_correlation() and other similar functions with
"struct netem_sched_data *q".

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c90de21..7e15f08 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -689,9 +689,8 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	return 0;
 }
 
-static void get_correlation(struct Qdisc *sch, const struct nlattr *attr)
+static void get_correlation(struct netem_sched_data *q, const struct nlattr *attr)
 {
-	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corr *c = nla_data(attr);
 
 	init_crandom(&q->delay_cor, c->delay_corr);
@@ -699,27 +698,24 @@ static void get_correlation(struct Qdisc *sch, const struct nlattr *attr)
 	init_crandom(&q->dup_cor, c->dup_corr);
 }
 
-static void get_reorder(struct Qdisc *sch, const struct nlattr *attr)
+static void get_reorder(struct netem_sched_data *q, const struct nlattr *attr)
 {
-	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_reorder *r = nla_data(attr);
 
 	q->reorder = r->probability;
 	init_crandom(&q->reorder_cor, r->correlation);
 }
 
-static void get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
+static void get_corrupt(struct netem_sched_data *q, const struct nlattr *attr)
 {
-	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corrupt *r = nla_data(attr);
 
 	q->corrupt = r->probability;
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
-static void get_rate(struct Qdisc *sch, const struct nlattr *attr)
+static void get_rate(struct netem_sched_data *q, const struct nlattr *attr)
 {
-	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_rate *r = nla_data(attr);
 
 	q->rate = r->rate;
@@ -730,9 +726,8 @@ static void get_rate(struct Qdisc *sch, const struct nlattr *attr)
 	q->cell_overhead = r->cell_overhead;
 }
 
-static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
+static int get_loss_clg(struct netem_sched_data *q, const struct nlattr *attr)
 {
-	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct nlattr *la;
 	int rem;
 
@@ -836,7 +831,7 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	old_loss_model = q->loss_model;
 
 	if (tb[TCA_NETEM_LOSS]) {
-		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
+		ret = get_loss_clg(q, tb[TCA_NETEM_LOSS]);
 		if (ret) {
 			q->loss_model = old_loss_model;
 			return ret;
@@ -874,16 +869,16 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 		q->reorder = ~0;
 
 	if (tb[TCA_NETEM_CORR])
-		get_correlation(sch, tb[TCA_NETEM_CORR]);
+		get_correlation(q, tb[TCA_NETEM_CORR]);
 
 	if (tb[TCA_NETEM_REORDER])
-		get_reorder(sch, tb[TCA_NETEM_REORDER]);
+		get_reorder(q, tb[TCA_NETEM_REORDER]);
 
 	if (tb[TCA_NETEM_CORRUPT])
-		get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
+		get_corrupt(q, tb[TCA_NETEM_CORRUPT]);
 
 	if (tb[TCA_NETEM_RATE])
-		get_rate(sch, tb[TCA_NETEM_RATE]);
+		get_rate(q, tb[TCA_NETEM_RATE]);
 
 	if (tb[TCA_NETEM_RATE64])
 		q->rate = max_t(u64, q->rate,
-- 
1.8.0
