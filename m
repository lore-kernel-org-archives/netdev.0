From: holger@eitzenberger.org
Subject: [patch 4/7] bonding: use pr_debug instead of own macros
Date: Tue, 09 Dec 2008 21:07:54 +0100
Message-ID: <20081209201448.662172844@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:49893 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbYLIUUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:20:00 -0500
Content-Disposition: inline; filename=bonding-use-pr_debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_debug() instead of own macros.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bonding.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bonding.h	2008-12-08 22:59:59.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bonding.h	2008-12-08 23:02:38.000000000 +0100
@@ -32,14 +32,6 @@
 
 extern struct list_head bond_dev_list;
 
-#ifdef BONDING_DEBUG
-#define dprintk(fmt, args...) \
-	printk(KERN_DEBUG     \
-	       DRV_NAME ": %s() %d: " fmt, __func__, __LINE__ , ## args )
-#else
-#define dprintk(fmt, args...)
-#endif /* BONDING_DEBUG */
-
 #define IS_UP(dev)					   \
 	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
 	       netif_running(dev)			&& \
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c	2008-12-08 22:42:32.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c	2008-12-08 23:02:38.000000000 +0100
@@ -20,8 +20,6 @@
  *
  */
 
-//#define BONDING_DEBUG 1
-
 #include <linux/skbuff.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
@@ -381,7 +379,7 @@
 		}
 	}
 
-	dprintk("Port %d Received link speed %d update from adapter\n", port->actor_port_number, speed);
+	pr_debug("Port %d Received link speed %d update from adapter\n", port->actor_port_number, speed);
 	return speed;
 }
 
@@ -407,12 +405,12 @@
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval=0x1;
-			dprintk("Port %d Received status full duplex update from adapter\n", port->actor_port_number);
+			pr_debug("Port %d Received status full duplex update from adapter\n", port->actor_port_number);
 			break;
 		case DUPLEX_HALF:
 		default:
 			retval=0x0;
-			dprintk("Port %d Received status NOT full duplex update from adapter\n", port->actor_port_number);
+			pr_debug("Port %d Received status NOT full duplex update from adapter\n", port->actor_port_number);
 			break;
 		}
 	}
@@ -1019,7 +1017,7 @@
 
 	// check if the state machine was changed
 	if (port->sm_mux_state != last_state) {
-		dprintk("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_mux_state);
+		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_mux_state);
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
 			__detach_bond_from_agg(port);
@@ -1118,7 +1116,7 @@
 
 	// check if the State machine was changed or new lacpdu arrived
 	if ((port->sm_rx_state != last_state) || (lacpdu)) {
-		dprintk("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_rx_state);
+		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_rx_state);
 		switch (port->sm_rx_state) {
 		case AD_RX_INITIALIZE:
 			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
@@ -1205,7 +1203,7 @@
 			__update_lacpdu_from_port(port);
 			// send the lacpdu
 			if (ad_lacpdu_send(port) >= 0) {
-				dprintk("Sent LACPDU on port %d\n", port->actor_port_number);
+				pr_debug("Sent LACPDU on port %d\n", port->actor_port_number);
 				// mark ntt as false, so it will not be sent again until demanded
 				port->ntt = 0;
 			}
@@ -1278,7 +1276,7 @@
 
 	// check if the state machine was changed
 	if (port->sm_periodic_state != last_state) {
-		dprintk("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_periodic_state);
+		pr_debug("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_periodic_state);
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
 			port->sm_periodic_timer_counter = 0;	   // zero timer
@@ -1335,7 +1333,7 @@
 				port->next_port_in_aggregator=NULL;
 				port->actor_port_aggregator_identifier=0;
 
-				dprintk("Port %d left LAG %d\n", port->actor_port_number, temp_aggregator->aggregator_identifier);
+				pr_debug("Port %d left LAG %d\n", port->actor_port_number, temp_aggregator->aggregator_identifier);
 				// if the aggregator is empty, clear its parameters, and set it ready to be attached
 				if (!temp_aggregator->lag_ports) {
 					ad_clear_agg(temp_aggregator);
@@ -1378,7 +1376,7 @@
 			port->next_port_in_aggregator=aggregator->lag_ports;
 			port->aggregator->num_of_ports++;
 			aggregator->lag_ports=port;
-			dprintk("Port %d joined LAG %d(existing LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+			pr_debug("Port %d joined LAG %d(existing LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
 
 			// mark this port as selected
 			port->sm_vars |= AD_PORT_SELECTED;
@@ -1415,7 +1413,7 @@
 			// mark this port as selected
 			port->sm_vars |= AD_PORT_SELECTED;
 
-			dprintk("Port %d joined LAG %d(new LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+			pr_debug("Port %d joined LAG %d(new LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
 		} else {
 			printk(KERN_ERR DRV_NAME ": %s: Port %d (on %s) did not find a suitable aggregator\n",
 			       port->slave->dev->master->name,
@@ -1574,19 +1572,19 @@
 
 	// if there is new best aggregator, activate it
 	if (best) {
-		dprintk("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 		       best->aggregator_identifier, best->num_of_ports,
 		       best->actor_oper_aggregator_key,
 		       best->partner_oper_aggregator_key,
 		       best->is_individual, best->is_active);
-		dprintk("best ports %p slave %p %s\n",
+		pr_debug("best ports %p slave %p %s\n",
 		       best->lag_ports, best->slave,
 		       best->slave ? best->slave->dev->name : "NULL");
 
 		for (agg = __get_first_agg(best->lag_ports); agg;
 		     agg = __get_next_agg(agg)) {
 
-			dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 				agg->aggregator_identifier, agg->num_of_ports,
 				agg->actor_oper_aggregator_key,
 				agg->partner_oper_aggregator_key,
@@ -1602,9 +1600,9 @@
 		}
 
 		best->is_active = 1;
-		dprintk("LAG %d chosen as the active LAG\n",
+		pr_debug("LAG %d chosen as the active LAG\n",
 			best->aggregator_identifier);
-		dprintk("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
+		pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 			best->aggregator_identifier, best->num_of_ports,
 			best->actor_oper_aggregator_key,
 			best->partner_oper_aggregator_key,
@@ -1662,7 +1660,7 @@
 		aggregator->lag_ports = NULL;
 		aggregator->is_active = 0;
 		aggregator->num_of_ports = 0;
-		dprintk("LAG %d was cleared\n", aggregator->aggregator_identifier);
+		pr_debug("LAG %d was cleared\n", aggregator->aggregator_identifier);
 	}
 }
 
@@ -1747,7 +1745,7 @@
 static void ad_enable_collecting_distributing(struct port *port)
 {
 	if (port->aggregator->is_active) {
-		dprintk("Enabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+		pr_debug("Enabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
 		__enable_port(port);
 	}
 }
@@ -1760,7 +1758,7 @@
 static void ad_disable_collecting_distributing(struct port *port)
 {
 	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
-		dprintk("Disabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+		pr_debug("Disabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
 		__disable_port(port);
 	}
 }
@@ -1798,7 +1796,7 @@
 
 	// send the marker information
 	if (ad_marker_send(port, &marker) >= 0) {
-		dprintk("Sent Marker Information on port %d\n", port->actor_port_number);
+		pr_debug("Sent Marker Information on port %d\n", port->actor_port_number);
 	}
 }
 #endif
@@ -1822,7 +1820,7 @@
 	// send the marker response
 
 	if (ad_marker_send(port, &marker) >= 0) {
-		dprintk("Sent Marker Response on port %d\n", port->actor_port_number);
+		pr_debug("Sent Marker Response on port %d\n", port->actor_port_number);
 	}
 }
 
@@ -2036,7 +2034,7 @@
 		return;
 	}
 
-	dprintk("Unbinding Link Aggregation Group %d\n", aggregator->aggregator_identifier);
+	pr_debug("Unbinding Link Aggregation Group %d\n", aggregator->aggregator_identifier);
 
 	/* Tell the partner that this port is not suitable for aggregation */
 	port->actor_oper_port_state &= ~AD_STATE_AGGREGATION;
@@ -2060,7 +2058,7 @@
 			// if new aggregator found, copy the aggregator's parameters
 			// and connect the related lag_ports to the new aggregator
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
-				dprintk("Some port(s) related to LAG %d - replaceing with LAG %d\n", aggregator->aggregator_identifier, new_aggregator->aggregator_identifier);
+				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n", aggregator->aggregator_identifier, new_aggregator->aggregator_identifier);
 
 				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
 					printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
@@ -2111,7 +2109,7 @@
 		}
 	}
 
-	dprintk("Unbinding port %d\n", port->actor_port_number);
+	pr_debug("Unbinding port %d\n", port->actor_port_number);
 	// find the aggregator that this port is connected to
 	temp_aggregator = __get_first_agg(port);
 	for (; temp_aggregator; temp_aggregator = __get_next_agg(temp_aggregator)) {
@@ -2242,7 +2240,7 @@
 
 		switch (lacpdu->subtype) {
 		case AD_TYPE_LACPDU:
-			dprintk("Received LACPDU on port %d\n", port->actor_port_number);
+			pr_debug("Received LACPDU on port %d\n", port->actor_port_number);
 			ad_rx_machine(lacpdu, port);
 			break;
 
@@ -2251,17 +2249,17 @@
 
 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
 			case AD_MARKER_INFORMATION_SUBTYPE:
-				dprintk("Received Marker Information on port %d\n", port->actor_port_number);
+				pr_debug("Received Marker Information on port %d\n", port->actor_port_number);
 				ad_marker_info_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			case AD_MARKER_RESPONSE_SUBTYPE:
-				dprintk("Received Marker Response on port %d\n", port->actor_port_number);
+				pr_debug("Received Marker Response on port %d\n", port->actor_port_number);
 				ad_marker_response_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			default:
-				dprintk("Received an unknown Marker subtype on slot %d\n", port->actor_port_number);
+				pr_debug("Received an unknown Marker subtype on slot %d\n", port->actor_port_number);
 			}
 		}
 	}
@@ -2289,7 +2287,7 @@
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 	port->actor_oper_port_key=port->actor_admin_port_key |= (__get_link_speed(port) << 1);
-	dprintk("Port %d changed speed\n", port->actor_port_number);
+	pr_debug("Port %d changed speed\n", port->actor_port_number);
 	// there is no need to reselect a new aggregator, just signal the
 	// state machines to reinitialize
 	port->sm_vars |= AD_PORT_BEGIN;
@@ -2317,7 +2315,7 @@
 
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 	port->actor_oper_port_key=port->actor_admin_port_key |= __get_duplex(port);
-	dprintk("Port %d changed duplex\n", port->actor_port_number);
+	pr_debug("Port %d changed duplex\n", port->actor_port_number);
 	// there is no need to reselect a new aggregator, just signal the
 	// state machines to reinitialize
 	port->sm_vars |= AD_PORT_BEGIN;
Index: bonding-2.6/drivers/net/bonding/bond_alb.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_alb.c	2008-12-08 22:42:32.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_alb.c	2008-12-08 23:00:01.000000000 +0100
@@ -20,8 +20,6 @@
  *
  */
 
-//#define BONDING_DEBUG 1
-
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -361,12 +359,12 @@
 		goto out;
 
 	if (!arp) {
-		dprintk("Packet has no ARP data\n");
+		pr_debug("Packet has no ARP data\n");
 		goto out;
 	}
 
 	if (skb->len < sizeof(struct arp_pkt)) {
-		dprintk("Packet is too small to be an ARP\n");
+		pr_debug("Packet is too small to be an ARP\n");
 		goto out;
 	}
 
@@ -376,7 +374,7 @@
 		       bond_dev->name);
 		bond = netdev_priv(bond_dev);
 		rlb_update_entry_from_arp(bond, arp);
-		dprintk("Server received an ARP Reply from client\n");
+		pr_debug("Server received an ARP Reply from client\n");
 	}
 
 	res = NET_RX_SUCCESS;
@@ -730,7 +728,7 @@
 		if (tx_slave) {
 			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
 		}
-		dprintk("Server sent ARP Reply packet\n");
+		pr_debug("Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
 		 * place holder.
@@ -750,7 +748,7 @@
 		 * updated with their assigned mac.
 		 */
 		rlb_req_update_subnet_clients(bond, arp->ip_src);
-		dprintk("Server sent ARP Request packet\n");
+		pr_debug("Server sent ARP Request packet\n");
 	}
 
 	return tx_slave;
Index: bonding-2.6/drivers/net/bonding/bond_ipv6.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_ipv6.c	2008-12-08 23:00:01.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_ipv6.c	2008-12-08 23:00:01.000000000 +0100
@@ -20,8 +20,6 @@
  *
  */
 
-//#define BONDING_DEBUG 1
-
 #include <linux/types.h>
 #include <linux/if_vlan.h>
 #include <net/ipv6.h>
@@ -74,7 +72,7 @@
 
 	addrconf_addr_solict_mult(daddr, &mcaddr);
 
-	dprintk("ipv6 na on slave %s: dest %pI6, src %pI6\n",
+	pr_debug("ipv6 na on slave %s: dest %pI6, src %pI6\n",
 	       slave_dev->name, &mcaddr, daddr);
 
 	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
@@ -110,7 +108,7 @@
 	struct inet6_dev *idev;
 	int is_router;
 
-	dprintk("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
+	pr_debug("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
 				slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_unsol_na ||
Index: bonding-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_main.c	2008-12-08 23:00:01.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_main.c	2008-12-08 23:02:38.000000000 +0100
@@ -31,8 +31,6 @@
  *
  */
 
-//#define BONDING_DEBUG 1
-
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -248,7 +246,7 @@
 {
 	struct vlan_entry *vlan;
 
-	dprintk("bond: %s, vlan id %d\n",
+	pr_debug("bond: %s, vlan id %d\n",
 		(bond ? bond->dev->name: "None"), vlan_id);
 
 	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
@@ -265,7 +263,7 @@
 
 	write_unlock_bh(&bond->lock);
 
-	dprintk("added VLAN ID %d on bond %s\n", vlan_id, bond->dev->name);
+	pr_debug("added VLAN ID %d on bond %s\n", vlan_id, bond->dev->name);
 
 	return 0;
 }
@@ -282,7 +280,7 @@
 	struct vlan_entry *vlan;
 	int res = -ENODEV;
 
-	dprintk("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
+	pr_debug("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
 	write_lock_bh(&bond->lock);
 
@@ -293,7 +291,7 @@
 			if (bond_is_lb(bond))
 				bond_alb_clear_vlan(bond, vlan_id);
 
-			dprintk("removed VLAN ID %d from bond %s\n", vlan_id,
+			pr_debug("removed VLAN ID %d from bond %s\n", vlan_id,
 				bond->dev->name);
 
 			kfree(vlan);
@@ -313,7 +311,7 @@
 		}
 	}
 
-	dprintk("couldn't find VLAN ID %d in bond %s\n", vlan_id,
+	pr_debug("couldn't find VLAN ID %d in bond %s\n", vlan_id,
 		bond->dev->name);
 
 out:
@@ -337,13 +335,13 @@
 
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->dev->features & NETIF_F_VLAN_CHALLENGED) {
-			dprintk("found VLAN challenged slave - %s\n",
+			pr_debug("found VLAN challenged slave - %s\n",
 				slave->dev->name);
 			return 1;
 		}
 	}
 
-	dprintk("no VLAN challenged slaves found\n");
+	pr_debug("no VLAN challenged slaves found\n");
 	return 0;
 }
 
@@ -1319,9 +1317,9 @@
 static int bond_sethwaddr(struct net_device *bond_dev,
 			  struct net_device *slave_dev)
 {
-	dprintk("bond_dev=%p\n", bond_dev);
-	dprintk("slave_dev=%p\n", slave_dev);
-	dprintk("slave_dev->addr_len=%d\n", slave_dev->addr_len);
+	pr_debug("bond_dev=%p\n", bond_dev);
+	pr_debug("slave_dev=%p\n", slave_dev);
+	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
 	return 0;
 }
@@ -1412,14 +1410,14 @@
 
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
-		dprintk("Error, Device was already enslaved\n");
+		pr_debug("Error, Device was already enslaved\n");
 		return -EBUSY;
 	}
 
 	/* vlan challenged mutual exclusion */
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
-		dprintk("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
 		if (!list_empty(&bond->vlan_list)) {
 			printk(KERN_ERR DRV_NAME
 			       ": %s: Error: cannot enslave VLAN "
@@ -1437,7 +1435,7 @@
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 		}
 	} else {
-		dprintk("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		pr_debug("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
 		if (bond->slave_cnt == 0) {
 			/* First slave, and it is not VLAN challenged,
 			 * so remove the block of adding VLANs over the bond.
@@ -1525,20 +1523,20 @@
 		addr.sa_family = slave_dev->type;
 		res = dev_set_mac_address(slave_dev, &addr);
 		if (res) {
-			dprintk("Error %d calling set_mac_address\n", res);
+			pr_debug("Error %d calling set_mac_address\n", res);
 			goto err_free;
 		}
 	}
 
 	res = netdev_set_master(slave_dev, bond_dev);
 	if (res) {
-		dprintk("Error %d calling netdev_set_master\n", res);
+		pr_debug("Error %d calling netdev_set_master\n", res);
 		goto err_restore_mac;
 	}
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
-		dprintk("Openning slave %s failed\n", slave_dev->name);
+		pr_debug("Openning slave %s failed\n", slave_dev->name);
 		goto err_unset_master;
 	}
 
@@ -1643,18 +1641,18 @@
 	if (!bond->params.miimon ||
 	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
 		if (bond->params.updelay) {
-			dprintk("Initial state of slave_dev is "
+			pr_debug("Initial state of slave_dev is "
 				"BOND_LINK_BACK\n");
 			new_slave->link  = BOND_LINK_BACK;
 			new_slave->delay = bond->params.updelay;
 		} else {
-			dprintk("Initial state of slave_dev is "
+			pr_debug("Initial state of slave_dev is "
 				"BOND_LINK_UP\n");
 			new_slave->link  = BOND_LINK_UP;
 		}
 		new_slave->jiffies = jiffies;
 	} else {
-		dprintk("Initial state of slave_dev is "
+		pr_debug("Initial state of slave_dev is "
 			"BOND_LINK_DOWN\n");
 		new_slave->link  = BOND_LINK_DOWN;
 	}
@@ -1715,7 +1713,7 @@
 		bond_set_slave_inactive_flags(new_slave);
 		break;
 	default:
-		dprintk("This slave is always active in trunk mode\n");
+		pr_debug("This slave is always active in trunk mode\n");
 
 		/* always active in trunk mode */
 		new_slave->state = BOND_STATE_ACTIVE;
@@ -2536,7 +2534,7 @@
 {
 	struct sk_buff *skb;
 
-	dprintk("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
+	pr_debug("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
 	       slave_dev->name, dest_ip, src_ip, vlan_id);
 	       
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
@@ -2569,9 +2567,9 @@
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 		if (!targets[i])
 			continue;
-		dprintk("basa: target %x\n", targets[i]);
+		pr_debug("basa: target %x\n", targets[i]);
 		if (list_empty(&bond->vlan_list)) {
-			dprintk("basa: empty vlan: arp_send\n");
+			pr_debug("basa: empty vlan: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
 			continue;
@@ -2601,7 +2599,7 @@
 		 */
 		if (rt->u.dst.dev == bond->dev) {
 			ip_rt_put(rt);
-			dprintk("basa: rtdev == bond->dev: arp_send\n");
+			pr_debug("basa: rtdev == bond->dev: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
 			continue;
@@ -2612,7 +2610,7 @@
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == rt->u.dst.dev) {
 				vlan_id = vlan->vlan_id;
-				dprintk("basa: vlan match on %s %d\n",
+				pr_debug("basa: vlan match on %s %d\n",
 				       vlan_dev->name, vlan_id);
 				break;
 			}
@@ -2647,7 +2645,7 @@
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 
-	dprintk("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
+	pr_debug("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
 				slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_grat_arp ||
@@ -2677,7 +2675,7 @@
 
 	targets = bond->params.arp_targets;
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
-		dprintk("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
+		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
 			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
 		if (sip == targets[i]) {
 			if (bond_has_this_ip(bond, tip))
@@ -2704,7 +2702,7 @@
 	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
-	dprintk("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
+	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
 		bond->dev->name, skb->dev ? skb->dev->name : "NULL",
 		orig_dev ? orig_dev->name : "NULL");
 
@@ -2730,7 +2728,7 @@
 	arp_ptr += 4 + dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
 
-	dprintk("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
+	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
 		bond->dev->name, slave->dev->name, slave->state,
 		bond->params.arp_validate, slave_do_arp_validate(bond, slave),
 		&sip, &tip);
@@ -3595,7 +3593,7 @@
 	if (dev_net(event_dev) != &init_net)
 		return NOTIFY_DONE;
 
-	dprintk("event_dev: %s, event: %lx\n",
+	pr_debug("event_dev: %s, event: %lx\n",
 		(event_dev ? event_dev->name : "None"),
 		event);
 
@@ -3603,12 +3601,12 @@
 		return NOTIFY_DONE;
 
 	if (event_dev->flags & IFF_MASTER) {
-		dprintk("IFF_MASTER\n");
+		pr_debug("IFF_MASTER\n");
 		return bond_master_netdev_event(event, event_dev);
 	}
 
 	if (event_dev->flags & IFF_SLAVE) {
-		dprintk("IFF_SLAVE\n");
+		pr_debug("IFF_SLAVE\n");
 		return bond_slave_netdev_event(event, event_dev);
 	}
 
@@ -3937,7 +3935,7 @@
 	struct mii_ioctl_data *mii = NULL;
 	int res = 0;
 
-	dprintk("bond_ioctl: master=%s, cmd=%d\n",
+	pr_debug("bond_ioctl: master=%s, cmd=%d\n",
 		bond_dev->name, cmd);
 
 	switch (cmd) {
@@ -4015,12 +4013,12 @@
 	down_write(&(bonding_rwsem));
 	slave_dev = dev_get_by_name(&init_net, ifr->ifr_slave);
 
-	dprintk("slave_dev=%p: \n", slave_dev);
+	pr_debug("slave_dev=%p: \n", slave_dev);
 
 	if (!slave_dev) {
 		res = -ENODEV;
 	} else {
-		dprintk("slave_dev->name=%s: \n", slave_dev->name);
+		pr_debug("slave_dev->name=%s: \n", slave_dev->name);
 		switch (cmd) {
 		case BOND_ENSLAVE_OLD:
 		case SIOCBONDENSLAVE:
@@ -4131,7 +4129,7 @@
 	int res = 0;
 	int i;
 
-	dprintk("bond=%p, name=%s, new_mtu=%d\n", bond,
+	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
 		(bond_dev ? bond_dev->name : "None"), new_mtu);
 
 	/* Can't hold bond->lock with bh disabled here since
@@ -4150,7 +4148,7 @@
 	 */
 
 	bond_for_each_slave(bond, slave, i) {
-		dprintk("s %p s->p %p c_m %p\n", slave,
+		pr_debug("s %p s->p %p c_m %p\n", slave,
 			slave->prev, slave->dev->change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
@@ -4164,7 +4162,7 @@
 			 * means changing their mtu from timer context, which
 			 * is probably not a good idea.
 			 */
-			dprintk("err %d %s\n", res, slave->dev->name);
+			pr_debug("err %d %s\n", res, slave->dev->name);
 			goto unwind;
 		}
 	}
@@ -4181,7 +4179,7 @@
 
 		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
 		if (tmp_res) {
-			dprintk("unwind err %d dev %s\n", tmp_res,
+			pr_debug("unwind err %d dev %s\n", tmp_res,
 				slave->dev->name);
 		}
 	}
@@ -4208,7 +4206,7 @@
 		return bond_alb_set_mac_address(bond_dev, addr);
 
 
-	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
+	pr_debug("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
 	/*
 	 * If fail_over_mac is set to active, do nothing and return
@@ -4238,11 +4236,11 @@
 
 	bond_for_each_slave(bond, slave, i) {
 		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
-		dprintk("slave %p %s\n", slave, slave->dev->name);
+		pr_debug("slave %p %s\n", slave, slave->dev->name);
 
 		if (slave_ops->ndo_set_mac_address == NULL) {
 			res = -EOPNOTSUPP;
-			dprintk("EOPNOTSUPP %s\n", slave->dev->name);
+			pr_debug("EOPNOTSUPP %s\n", slave->dev->name);
 			goto unwind;
 		}
 
@@ -4254,7 +4252,7 @@
 			 * breakage anyway until ARP finish
 			 * updating, so...
 			 */
-			dprintk("err %d %s\n", res, slave->dev->name);
+			pr_debug("err %d %s\n", res, slave->dev->name);
 			goto unwind;
 		}
 	}
@@ -4274,7 +4272,7 @@
 
 		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
 		if (tmp_res) {
-			dprintk("unwind err %d dev %s\n", tmp_res,
+			pr_debug("unwind err %d dev %s\n", tmp_res,
 				slave->dev->name);
 		}
 	}
@@ -4593,7 +4591,7 @@
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	dprintk("Begin bond_init for %s\n", bond_dev->name);
+	pr_debug("Begin bond_init for %s\n", bond_dev->name);
 
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
Index: bonding-2.6/drivers/net/bonding/bond_sysfs.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_sysfs.c	2008-12-08 22:42:32.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_sysfs.c	2008-12-08 23:02:38.000000000 +0100
@@ -36,8 +36,8 @@
 #include <linux/rtnetlink.h>
 #include <net/net_namespace.h>
 
-/* #define BONDING_DEBUG 1 */
 #include "bonding.h"
+
 #define to_dev(obj)	container_of(obj,struct device,kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 

-- 
