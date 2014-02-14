From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 5/7] sch_netem: clear old corrupt when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:08 +0800
Message-ID: <1392366970-11592-6-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58743 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbaBNIg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:27 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with corrupt option, while we
use "#tc qdisc replace ..." that without corrupt option
to replace the old qdisc, the old corrupt is still there.
We need clear old corrupt after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 33e7cef..2f630e9 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -732,6 +732,12 @@ static void get_corrupt(struct netem_sched_data *q, const struct nlattr *attr)
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
+static void corrupt_reset(struct netem_sched_data *q)
+{
+	q->corrupt = 0;
+	memset(&q->corrupt_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_rate(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_rate *r = nla_data(attr);
@@ -907,6 +913,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(q, tb[TCA_NETEM_CORRUPT]);
+	else
+		corrupt_reset(q);
 
 	if (tb[TCA_NETEM_RATE])
 		get_rate(q, tb[TCA_NETEM_RATE]);
-- 
1.8.0
