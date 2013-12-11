From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] sch_htb: remove unnecessary NULL pointer judgment
Date: Wed, 11 Dec 2013 15:48:37 +0800
Message-ID: <1386748117-27072-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:51684 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3LKHwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 02:52:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It already has a NULL pointer judgment of rtab in qdisc_put_rtab().
Remove the judgment outside of qdisc_put_rtab().

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_htb.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0e1e38b..830c64f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1337,7 +1337,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)*arg, *parent;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
 	struct nlattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_opt *hopt;
 	u64 rate64, ceil64;
@@ -1361,16 +1360,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		goto failure;
 
 	/* Keeping backward compatible with rate_table based iproute2 tc */
-	if (hopt->rate.linklayer == TC_LINKLAYER_UNAWARE) {
-		rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB]);
-		if (rtab)
-			qdisc_put_rtab(rtab);
-	}
-	if (hopt->ceil.linklayer == TC_LINKLAYER_UNAWARE) {
-		ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB]);
-		if (ctab)
-			qdisc_put_rtab(ctab);
-	}
+	if (hopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
+		qdisc_put_rtab(qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB]));
+
+	if (hopt->ceil.linklayer == TC_LINKLAYER_UNAWARE)
+		qdisc_put_rtab(qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB]));
 
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
-- 
1.8.0
