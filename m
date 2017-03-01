From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net] bridge: Fix error path in nbp_vlan_init
Date: Wed,  1 Mar 2017 16:50:45 +0200
Message-ID: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        idosch@mellanox.com, eladr@mellanox.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55292 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751742AbdCAQtn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 11:49:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix error path order in nbp_vlan_init, so if switchdev_port_attr_set
call failes, the vlan_hash wouldn't be destroyed before inited.

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/bridge/br_vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 62e68c0..b838213 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -997,10 +997,10 @@ int nbp_vlan_init(struct net_bridge_port *p)
 	RCU_INIT_POINTER(p->vlgrp, NULL);
 	synchronize_rcu();
 	vlan_tunnel_deinit(vg);
-err_vlan_enabled:
 err_tunnel_init:
 	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
+err_vlan_enabled:
 	kfree(vg);
 
 	goto out;
-- 
2.4.11
