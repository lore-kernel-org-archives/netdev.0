From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] openvswitch: correct an invalid BUG_ON
Date: Wed, 27 Mar 2013 20:41:17 +0800
Message-ID: <1364388077-30480-1-git-send-email-honkiko@gmail.com>
Cc: dev@openvswitch.org, davem@davemloft.net,
	stephen@networkplumber.org, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:34540 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081Ab3C0Ml3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 08:41:29 -0400
Received: by mail-pb0-f50.google.com with SMTP id jt11so989164pbb.9
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 05:41:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

table->count is uint32_t

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/openvswitch/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fe0e421..67a2b78 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -795,9 +795,9 @@ void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
 
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
+	BUG_ON(table->count == 0);
 	hlist_del_rcu(&flow->hash_node[table->node_ver]);
 	table->count--;
-	BUG_ON(table->count < 0);
 }
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
-- 
1.7.10.4
