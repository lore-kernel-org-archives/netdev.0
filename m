From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 1/3] net: flow: export net_flow_{put_rule,get_{field,action}}
Date: Wed, 18 Feb 2015 14:25:57 -0500
Message-ID: <1424287559-25700-2-git-send-email-simon.horman@netronome.com>
References: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:40673 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbbBRT0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 14:26:23 -0500
Received: by yhot59 with SMTP id t59so2213204yho.7
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 11:26:22 -0800 (PST)
In-Reply-To: <1424287559-25700-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*** Not for Upstream Merge
*** For informational purposes only

This is to allow these functions to be used by a new driver, unft,
which will be proposed in a subsequent patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/if_flow.h |  6 ++++++
 net/core/flow_table.c   | 10 ++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
index dc70e3e..eb19b6c8 100644
--- a/include/linux/if_flow.h
+++ b/include/linux/if_flow.h
@@ -225,4 +225,10 @@ net_flow_destroy_cache(struct net_flow_tbl *table)
 	return;
 }
 #endif /* CONFIG_NET_FLOW_TABLES */
+
+struct nlattr;
+
+int net_flow_put_rule(struct sk_buff *skb, struct net_flow_rule *rule);
+int net_flow_get_field(struct net_flow_field_ref *field, struct nlattr *nla);
+int net_flow_get_action(struct net_flow_action *action, struct nlattr *nla);
 #endif /* _IF_FLOW_H_ */
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index a938929..8c26019 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -975,7 +975,7 @@ done:
 	return 0;
 }
 
-static int net_flow_put_rule(struct sk_buff *skb, struct net_flow_rule *rule)
+int net_flow_put_rule(struct sk_buff *skb, struct net_flow_rule *rule)
 {
 	struct nlattr *flows, *actions, *matches;
 	int j, i = 0;
@@ -1039,6 +1039,7 @@ flows_put_failure:
 put_failure:
 	return err;
 }
+EXPORT_SYMBOL(net_flow_put_rule);
 
 static int net_flow_get_rule_cache(struct sk_buff *skb,
 				   struct net_flow_tbl *table,
@@ -1233,8 +1234,7 @@ const struct nla_policy net_flow_field_policy[NFL_FIELD_REF_MAX + 1] = {
 				      .len = sizeof(u64)},
 };
 
-static int net_flow_get_field(struct net_flow_field_ref *field,
-			      struct nlattr *nla)
+int net_flow_get_field(struct net_flow_field_ref *field, struct nlattr *nla)
 {
 	struct nlattr *ref[NFL_FIELD_REF_MAX+1];
 	int err;
@@ -1332,6 +1332,7 @@ static int net_flow_get_field(struct net_flow_field_ref *field,
 
 	return err;
 }
+EXPORT_SYMBOL(net_flow_get_field);
 
 static void net_flow_free_actions(struct net_flow_action *actions)
 {
@@ -1420,7 +1421,7 @@ static int net_flow_get_actarg(struct net_flow_action_arg *arg,
 	return 0;
 }
 
-static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
+int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
 {
 	struct nlattr *act[NFL_ACTION_ATTR_MAX+1];
 	struct nlattr *args;
@@ -1470,6 +1471,7 @@ static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(net_flow_get_action);
 
 static const
 struct nla_policy net_flow_rule_policy[NFL_ATTR_MAX + 1] = {
-- 
2.1.4
