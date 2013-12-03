From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 3/5] net_sched: Provide default walker function for actions
Date: Tue,  3 Dec 2013 09:23:17 -0500
Message-ID: <1386080600-4067-4-git-send-email-jhs@mojatatu.com>
References: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:62252 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab3LCOYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:24:24 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so23809360iej.14
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 06:24:24 -0800 (PST)
In-Reply-To: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 053a115..401eca8 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -280,8 +280,11 @@ int tcf_register_action(struct tc_action_ops *act)
 	act->next = NULL;
 	*ap = act;
 
+	/* Supply defaults */
 	if (!act->lookup)
 		act->lookup = tcf_hash_search;
+	if (!act->walk)
+		act->walk = tcf_generic_walker;
 
 	write_unlock(&act_mod_lock);
 	return 0;
@@ -1086,12 +1089,6 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	memset(&a, 0, sizeof(struct tc_action));
 	a.ops = a_o;
 
-	if (a_o->walk == NULL) {
-		WARN(1, "tc_dump_action: %s !capable of dumping table\n",
-		     a_o->kind);
-		goto out_module_put;
-	}
-
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
-- 
1.7.10.4
