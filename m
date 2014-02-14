From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 4/7] sch_netem: clear old correlation when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:07 +0800
Message-ID: <1392366970-11592-5-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58744 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaBNIg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:27 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with correlation option, while we
use "#tc qdisc replace ..." that without correlation option
to replace the old qdisc, the old correlation is still there.
We need clear old correlation after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bb06dd8..33e7cef 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -703,6 +703,13 @@ static void get_correlation(struct netem_sched_data *q, const struct nlattr *att
 	init_crandom(&q->dup_cor, c->dup_corr);
 }
 
+static void correlation_reset(struct netem_sched_data *q)
+{
+	memset(&q->delay_cor, 0, sizeof(struct crndstate));
+	memset(&q->loss_cor, 0, sizeof(struct crndstate));
+	memset(&q->dup_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_reorder(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_reorder *r = nla_data(attr);
@@ -890,6 +897,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_NETEM_CORR])
 		get_correlation(q, tb[TCA_NETEM_CORR]);
+	else
+		correlation_reset(q);
 
 	if (tb[TCA_NETEM_REORDER])
 		get_reorder(q, tb[TCA_NETEM_REORDER]);
-- 
1.8.0
