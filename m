From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 4/5] tipc: add a function to get the bearer name
Date: Tue, 26 Jul 2016 08:47:21 +0200
Message-ID: <1469515642-9498-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:50669 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbcGZGri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 02:47:38 -0400
In-Reply-To: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new function to get the bearer name from
its id. This is used in subsequent commit.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/bearer.c | 21 +++++++++++++++++++++
 net/tipc/bearer.h |  1 +
 2 files changed, 22 insertions(+)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 65b0998a9bab..65b1bbf133bd 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -171,6 +171,27 @@ struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name)
 	return NULL;
 }
 
+/*     tipc_bearer_get_name - get the bearer name from its id.
+ *     @net: network namespace
+ *     @name: a pointer to the buffer where the name will be stored.
+ *     @bearer_id: the id to get the name from.
+ */
+int tipc_bearer_get_name(struct net *net, char *name, u32 bearer_id)
+{
+	struct tipc_net *tn = tipc_net(net);
+	struct tipc_bearer *b;
+
+	if (bearer_id >= MAX_BEARERS)
+		return -EINVAL;
+
+	b = rtnl_dereference(tn->bearer_list[bearer_id]);
+	if (!b)
+		return -EINVAL;
+
+	strcpy(name, b->name);
+	return 0;
+}
+
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index f1e6db5e6345..43757f1f9cb3 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -197,6 +197,7 @@ int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
 void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest);
 struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name);
+int tipc_bearer_get_name(struct net *net, char *name, u32 bearer_id);
 struct tipc_media *tipc_media_find(const char *name);
 void tipc_bearer_reset_all(struct net *net);
 int tipc_bearer_setup(void);
-- 
2.1.4
