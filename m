From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/13] rocker: return -EOPNOTSUPP for undefined world ops
Date: Tue, 16 Feb 2016 13:55:38 +0100
Message-ID: <1455627338-9872-14-git-send-email-jiri@resnulli.us>
References: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:32845 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137AbcBPMz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:55:59 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so190330584wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:55:58 -0800 (PST)
In-Reply-To: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker_main.c | 33 ++++++++++++++++---------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 1efd8b7..acafbf8 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1547,7 +1547,7 @@ static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_attr_stp_state_set)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_attr_stp_state_set(rocker_port, state, trans);
 }
 
@@ -1559,7 +1559,7 @@ rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_attr_bridge_flags_set)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_attr_bridge_flags_set(rocker_port, brport_flags,
 						trans);
 }
@@ -1571,7 +1571,7 @@ rocker_world_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_attr_bridge_flags_get)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_attr_bridge_flags_get(rocker_port, p_brport_flags);
 }
 
@@ -1584,7 +1584,7 @@ rocker_world_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_attr_bridge_ageing_time_set)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_attr_bridge_ageing_time_set(rocker_port, ageing_time,
 						      trans);
 }
@@ -1597,6 +1597,7 @@ rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_vlan_add)
+		return -EOPNOTSUPP;
 		return 0;
 	return wops->port_obj_vlan_add(rocker_port, vlan, trans);
 }
@@ -1608,7 +1609,7 @@ rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_vlan_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_vlan_del(rocker_port, vlan);
 }
 
@@ -1620,7 +1621,7 @@ rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_vlan_dump)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_vlan_dump(rocker_port, vlan, cb);
 }
 
@@ -1632,7 +1633,7 @@ rocker_world_port_obj_fib4_add(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_fib4_add)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_fib4_add(rocker_port, fib4, trans);
 }
 
@@ -1643,7 +1644,7 @@ rocker_world_port_obj_fib4_del(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_fib4_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_fib4_del(rocker_port, fib4);
 }
 
@@ -1655,7 +1656,7 @@ rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_fdb_add)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_fdb_add(rocker_port, fdb, trans);
 }
 
@@ -1666,7 +1667,7 @@ rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_fdb_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_fdb_del(rocker_port, fdb);
 }
 
@@ -1678,7 +1679,7 @@ rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_obj_fdb_dump)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_obj_fdb_dump(rocker_port, fdb, cb);
 }
 
@@ -1688,7 +1689,7 @@ static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_master_linked)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_master_linked(rocker_port, master);
 }
 
@@ -1698,7 +1699,7 @@ static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_master_unlinked)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_master_unlinked(rocker_port, master);
 }
 
@@ -1708,7 +1709,7 @@ static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_neigh_update)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_neigh_update(rocker_port, n);
 }
 
@@ -1718,7 +1719,7 @@ static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_neigh_destroy)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_neigh_destroy(rocker_port, n);
 }
 
@@ -1729,7 +1730,7 @@ static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 	struct rocker_world_ops *wops = rocker_port->rocker->wops;
 
 	if (!wops->port_ev_mac_vlan_seen)
-		return 0;
+		return -EOPNOTSUPP;
 	return wops->port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
 }
 
-- 
1.9.3
