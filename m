From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/bridge: Use RCU_INIT_POINTER(x, NULL) in br_vlan.c
Date: Mon, 24 Mar 2014 00:41:13 +0530
Message-ID: <1395601873-12447-1-git-send-email-monamagarwal123@gmail.com>
To: stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:47891 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaCWTMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 15:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/bridge/br_vlan.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 8249ca7..5d5b101 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -99,9 +99,9 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	v->num_vlans--;
 	if (bitmap_empty(v->vlan_bitmap, VLAN_N_VID)) {
 		if (v->port_idx)
-			rcu_assign_pointer(v->parent.port->vlan_info, NULL);
+			RCU_INIT_POINTER(v->parent.port->vlan_info, NULL);
 		else
-			rcu_assign_pointer(v->parent.br->vlan_info, NULL);
+			RCU_INIT_POINTER(v->parent.br->vlan_info, NULL);
 		kfree_rcu(v, rcu);
 	}
 	return 0;
@@ -113,9 +113,9 @@ static void __vlan_flush(struct net_port_vlans *v)
 	v->pvid = 0;
 	bitmap_zero(v->vlan_bitmap, VLAN_N_VID);
 	if (v->port_idx)
-		rcu_assign_pointer(v->parent.port->vlan_info, NULL);
+		RCU_INIT_POINTER(v->parent.port->vlan_info, NULL);
 	else
-		rcu_assign_pointer(v->parent.br->vlan_info, NULL);
+		RCU_INIT_POINTER(v->parent.br->vlan_info, NULL);
 	kfree_rcu(v, rcu);
 }
 
-- 
1.7.9.5
