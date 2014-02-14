From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 6/7] sch_netem: clear old rate when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:09 +0800
Message-ID: <1392366970-11592-7-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44708 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbaBNIgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:36 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with rate option, while we
use "#tc qdisc replace ..." that without rate option
to replace the old qdisc, the old rate is still there.
We need clear old rate after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2f630e9..92f6ba6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -752,6 +752,15 @@ static void get_rate(struct netem_sched_data *q, const struct nlattr *attr)
 		q->cell_size_reciprocal = (struct reciprocal_value) { 0 };
 }
 
+static void rate_reset(struct netem_sched_data *q)
+{
+	q->rate = 0;
+	q->packet_overhead = 0;
+	q->cell_size = 0;
+	q->cell_size_reciprocal = (struct reciprocal_value) { 0 };
+	q->cell_overhead = 0;
+}
+
 static int get_loss_clg(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct nlattr *la;
@@ -918,6 +927,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_NETEM_RATE])
 		get_rate(q, tb[TCA_NETEM_RATE]);
+	else
+		rate_reset(q);
 
 	if (tb[TCA_NETEM_RATE64])
 		q->rate = max_t(u64, q->rate,
-- 
1.8.0
