From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH] net: flow: Guard against accessing non-existent attributes
Date: Mon, 29 Dec 2014 11:17:35 +0900
Message-ID: <1419819455-19109-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64431 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbaL2CR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:17:57 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so16247711pde.40
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 5937fb7..df2adf6 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -480,6 +480,10 @@ static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
 	if (err < 0)
 		return err;
 
+	if (!act[NET_FLOW_ACTION_ATTR_UID] ||
+	    !act[NET_FLOW_ACTION_ATTR_SIGNATURE])
+		return -EINVAL;
+
 	a->uid = nla_get_u32(act[NET_FLOW_ACTION_ATTR_UID]);
 
 	nla_for_each_nested(args, act[NET_FLOW_ACTION_ATTR_SIGNATURE], rem)
@@ -513,6 +517,10 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 	if (err < 0)
 		return -EINVAL;
 
+	if (!f[NET_FLOW_ATTR_TABLE] || !f[NET_FLOW_ATTR_UID] ||
+	    !f[NET_FLOW_ATTR_PRIORITY])
+		return -EINVAL;
+
 	flow->table_id = nla_get_u32(f[NET_FLOW_ATTR_TABLE]);
 	flow->uid = nla_get_u32(f[NET_FLOW_ATTR_UID]);
 	flow->priority = nla_get_u32(f[NET_FLOW_ATTR_PRIORITY]);
@@ -1209,6 +1217,9 @@ static int net_flow_table_cmd_get_flows(struct sk_buff *skb,
 	if (err)
 		goto out;
 
+	if (!tb[NET_FLOW_TABLE_FLOWS_TABLE])
+		goto out;
+
 	table = nla_get_u32(tb[NET_FLOW_TABLE_FLOWS_TABLE]);
 
 	if (tb[NET_FLOW_TABLE_FLOWS_MINPRIO])
-- 
2.1.3
