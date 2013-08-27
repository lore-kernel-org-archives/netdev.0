From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 03/11] openvswitch: Use non rcu hlist_del() flow table entry.
Date: Tue, 27 Aug 2013 13:20:40 -0700
Message-ID: <1377634848-34327-4-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:49049 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752769Ab3H0UVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:02 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5316639pad.33
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:02 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Flow table destroy is done in rcu call-back context.  Therefore
there is no need to use rcu variant of hlist_del().

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 1aa84dc..fca2825 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -302,7 +302,7 @@ void ovs_flow_tbl_destroy(struct flow_table *table)
 		int ver = table->node_ver;
 
 		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
-			hlist_del_rcu(&flow->hash_node[ver]);
+			hlist_del(&flow->hash_node[ver]);
 			ovs_flow_free(flow);
 		}
 	}
-- 
1.8.1.2
