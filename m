From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 07/20] net: sched: remove check for number of actions in tcf_exts_exec
Date: Fri,  4 Aug 2017 14:29:02 +0200
Message-ID: <20170804122915.15177-8-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34595 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752491AbdHDM3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id x64so5550822wmg.1
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:32 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Leave it to tcf_action_exec to return TC_ACT_OK in case there is no
action present.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 4 +---
 net/sched/act_api.c   | 3 ++-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 61ce521..b8959c9 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -192,9 +192,7 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	      struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (tcf_exts_has_actions(exts))
-		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
-				       res);
+	return tcf_action_exec(skb, exts->actions, exts->nr_actions, res);
 #endif
 	return TC_ACT_OK;
 }
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f19b118..a2915d9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -473,9 +473,10 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		    int nr_actions, struct tcf_result *res)
 {
-	int ret = -1, i;
 	u32 jmp_prgcnt = 0;
 	u32 jmp_ttl = TCA_ACT_MAX_PRIO; /*matches actions per filter */
+	int i;
+	int ret = TC_ACT_OK;
 
 	if (skb_skip_tc_classify(skb))
 		return TC_ACT_OK;
-- 
2.9.3
