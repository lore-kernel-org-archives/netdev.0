From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 4/5] net_sched: Provide default walker function for actions
Date: Wed,  4 Dec 2013 09:26:55 -0500
Message-ID: <1386167216-30281-5-git-send-email-jhs@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:38849 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab3LDO1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:42 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so26074018iec.23
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:41 -0800 (PST)
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d1a022e..69cb848 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -274,8 +274,11 @@ int tcf_register_action(struct tc_action_ops *act)
 	if (!act->act || !act->dump || !act->cleanup || !act->init)
 		return -EINVAL;
 
+	/* Supply defaults */
 	if (!act->lookup)
 		act->lookup = tcf_hash_search;
+	if (!act->walk)
+		act->walk = tcf_generic_walker;
 
 	write_lock(&act_mod_lock);
 	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
@@ -1089,12 +1092,6 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
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
