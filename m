From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 3/5] sch_tbf: change name "tbf_change" to "tbf_replace"
Date: Thu, 6 Mar 2014 21:08:39 +0800
Message-ID: <1394111321-11192-4-git-send-email-yangyingliang@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62587 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbaCFNKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:10:02 -0500
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tbf_change will clear all options when we change the parameters
that specified in the command line. So it should be "tbf_replace",
then add a new "tbf_change" in next patch for just changing the
parameters.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 87a02bfa707b..e9f373effd5f 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -308,7 +308,7 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
 	[TCA_TBF_PBURST] = { .type = NLA_U32 },
 };
 
-static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
+static int tbf_replace(struct Qdisc *sch, struct nlattr *opt)
 {
 	int err;
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -435,7 +435,7 @@ static int tbf_init(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
-	return tbf_change(sch, opt);
+	return tbf_replace(sch, opt);
 }
 
 static void tbf_destroy(struct Qdisc *sch)
@@ -560,7 +560,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
 	.destroy	=	tbf_destroy,
-	.change		=	tbf_change,
+	.replace	=	tbf_replace,
 	.dump		=	tbf_dump,
 	.owner		=	THIS_MODULE,
 };
-- 
1.8.0
