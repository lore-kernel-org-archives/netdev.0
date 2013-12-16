From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 1/8] net_sched: remove get_stats from tc_action_ops
Date: Sun, 15 Dec 2013 20:15:04 -0800
Message-ID: <1387167311-14763-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56814 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab3LPEPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:23 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so2410713pab.0
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:23 -0800 (PST)
In-Reply-To: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not used.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h | 1 -
 net/sched/act_api.c   | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9e90fdf..04c6825 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -72,7 +72,6 @@ struct tc_action_ops {
 	__u32 	capab;  /* capabilities includes 4 bit version */
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
-	int     (*get_stats)(struct sk_buff *, struct tc_action *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	int     (*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct tc_action *, u32);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 4adbce8..51e28f7 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -637,10 +637,6 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (err < 0)
 		goto errout;
 
-	if (a->ops != NULL && a->ops->get_stats != NULL)
-		if (a->ops->get_stats(skb, a) < 0)
-			goto errout;
-
 	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &h->tcf_bstats,
 				     &h->tcf_rate_est) < 0 ||
-- 
1.8.1.4
