From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 2/2] openvswitch: correct an invalid BUG_ON
Date: Tue, 16 Apr 2013 13:17:29 -0700
Message-ID: <1366143449-8605-3-git-send-email-jesse@nicira.com>
References: <1366143449-8605-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Hong Zhiguo <honkiko@gmail.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:35809 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S964873Ab3DPUR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:17:26 -0400
Received: by mail-pb0-f71.google.com with SMTP id md4so703584pbc.2
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 13:17:24 -0700 (PDT)
In-Reply-To: <1366143449-8605-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>

table->count is uint32_t

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
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
