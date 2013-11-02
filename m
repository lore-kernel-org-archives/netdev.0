From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 11/11] openvswitch: Use flow hash during flow lookup operation.
Date: Sat,  2 Nov 2013 00:43:50 -0700
Message-ID: <1383378230-59624-12-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:42791 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754677Ab3KBVym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:54:42 -0400
Received: by mail-pd0-f171.google.com with SMTP id w10so5208683pde.16
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:54:41 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Flow->hash can be used to detect hash collisions and avoid flow key
compare in flow lookup.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 536b4d2..e425427 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -421,7 +421,7 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	hash = flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(ti, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
-		if (flow->mask == mask &&
+		if (flow->mask == mask && flow->hash == hash &&
 		    flow_cmp_masked_key(flow, &masked_key,
 					  key_start, key_end))
 			return flow;
-- 
1.8.3.2
