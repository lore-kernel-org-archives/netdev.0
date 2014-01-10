From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 7/7] net_sched: act: remove struct tcf_act_hdr
Date: Thu,  9 Jan 2014 16:14:05 -0800
Message-ID: <1389312845-10304-8-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37510 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369AbaAJAOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:45 -0500
Received: by mail-pd0-f179.google.com with SMTP id y13so1318583pdi.10
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:44 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not necessary at all.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  4 ----
 net/sched/act_api.c   | 16 ++++++++--------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 268f9e6..e171387 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -73,10 +73,6 @@ static inline void tcf_hashinfo_destroy(struct tcf_hashinfo *hf)
 #define ACT_P_CREATED 1
 #define ACT_P_DELETED 1
 
-struct tcf_act_hdr {
-	struct tcf_common	common;
-};
-
 struct tc_action {
 	void			*priv;
 	const struct tc_action_ops	*ops;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 178bf2e..35f89e9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -556,9 +556,9 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 {
 	int err = 0;
 	struct gnet_dump d;
-	struct tcf_act_hdr *h = a->priv;
+	struct tcf_common *p = a->priv;
 
-	if (h == NULL)
+	if (p == NULL)
 		goto errout;
 
 	/* compat_mode being true specifies a call that is supposed
@@ -567,20 +567,20 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (compat_mode) {
 		if (a->type == TCA_OLD_COMPAT)
 			err = gnet_stats_start_copy_compat(skb, 0,
-				TCA_STATS, TCA_XSTATS, &h->tcf_lock, &d);
+				TCA_STATS, TCA_XSTATS, &p->tcfc_lock, &d);
 		else
 			return 0;
 	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
-					    &h->tcf_lock, &d);
+					    &p->tcfc_lock, &d);
 
 	if (err < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &h->tcf_bstats,
-				     &h->tcf_rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
+	if (gnet_stats_copy_basic(&d, &p->tcfc_bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
+				     &p->tcfc_rate_est) < 0 ||
+	    gnet_stats_copy_queue(&d, &p->tcfc_qstats) < 0)
 		goto errout;
 
 	if (gnet_stats_finish_copy(&d) < 0)
-- 
1.8.3.1
