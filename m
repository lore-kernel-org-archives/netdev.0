From: Joe Perches <joe@perches.com>
Subject: [PATCH 19/21] drivers/net/bonding/: : use pr_fmt
Date: Sun,  4 Oct 2009 17:53:46 -0700
Message-ID: <ec7e258261ac67ba496f96d04c270cf89fc24deb.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1723 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758296AbZJEAze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Oct 2009 20:55:34 -0400
In-Reply-To: <cover.1254701151.git.joe@perches.com>
In-Reply-To: <cover.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove DRV_NAME from pr_<level>s
Consolidate long format strings
Remove some extra tab indents
Remove some unnecessary ()s from pr_<level>s arguments
Align pr_<level> arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c   |  171 ++++++-----
 drivers/net/bonding/bond_alb.c   |   38 +--
 drivers/net/bonding/bond_ipv6.c  |   12 +-
 drivers/net/bonding/bond_main.c  |  608 ++++++++++++++------------------------
 drivers/net/bonding/bond_sysfs.c |  322 ++++++++------------
 5 files changed, 464 insertions(+), 687 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c3fa31c..b1a7dac 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -20,6 +20,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/skbuff.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
@@ -352,7 +354,8 @@ static u16 __get_link_speed(struct port *port)
 		}
 	}
 
-	pr_debug("Port %d Received link speed %d update from adapter\n", port->actor_port_number, speed);
+	pr_debug("Port %d Received link speed %d update from adapter\n",
+		 port->actor_port_number, speed);
 	return speed;
 }
 
@@ -378,12 +381,14 @@ static u8 __get_duplex(struct port *port)
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval=0x1;
-			pr_debug("Port %d Received status full duplex update from adapter\n", port->actor_port_number);
+			pr_debug("Port %d Received status full duplex update from adapter\n",
+				 port->actor_port_number);
 			break;
 		case DUPLEX_HALF:
 		default:
 			retval=0x0;
-			pr_debug("Port %d Received status NOT full duplex update from adapter\n", port->actor_port_number);
+			pr_debug("Port %d Received status NOT full duplex update from adapter\n",
+				 port->actor_port_number);
 			break;
 		}
 	}
@@ -978,7 +983,9 @@ static void ad_mux_machine(struct port *port)
 
 	// check if the state machine was changed
 	if (port->sm_mux_state != last_state) {
-		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_mux_state);
+		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n",
+			 port->actor_port_number, last_state,
+			 port->sm_mux_state);
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
 			__detach_bond_from_agg(port);
@@ -1077,7 +1084,9 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 
 	// check if the State machine was changed or new lacpdu arrived
 	if ((port->sm_rx_state != last_state) || (lacpdu)) {
-		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_rx_state);
+		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n",
+			 port->actor_port_number, last_state,
+			 port->sm_rx_state);
 		switch (port->sm_rx_state) {
 		case AD_RX_INITIALIZE:
 			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
@@ -1124,9 +1133,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			// detect loopback situation
 			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
 				// INFO_RECEIVED_LOOPBACK_FRAMES
-				pr_err(DRV_NAME ": %s: An illegal loopback occurred on "
-				       "adapter (%s). Check the configuration to verify that all "
-				       "Adapters are connected to 802.3ad compliant switch ports\n",
+				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
+				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
 				       port->slave->dev->master->name, port->slave->dev->name);
 				__release_rx_machine_lock(port);
 				return;
@@ -1165,7 +1173,8 @@ static void ad_tx_machine(struct port *port)
 			__update_lacpdu_from_port(port);
 
 			if (ad_lacpdu_send(port) >= 0) {
-				pr_debug("Sent LACPDU on port %d\n", port->actor_port_number);
+				pr_debug("Sent LACPDU on port %d\n",
+					 port->actor_port_number);
 
 				/* mark ntt as false, so it will not be sent again until
 				   demanded */
@@ -1240,7 +1249,9 @@ static void ad_periodic_machine(struct port *port)
 
 	// check if the state machine was changed
 	if (port->sm_periodic_state != last_state) {
-		pr_debug("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n", port->actor_port_number, last_state, port->sm_periodic_state);
+		pr_debug("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n",
+			 port->actor_port_number, last_state,
+			 port->sm_periodic_state);
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
 			port->sm_periodic_timer_counter = 0;	   // zero timer
@@ -1297,7 +1308,9 @@ static void ad_port_selection_logic(struct port *port)
 				port->next_port_in_aggregator=NULL;
 				port->actor_port_aggregator_identifier=0;
 
-				pr_debug("Port %d left LAG %d\n", port->actor_port_number, temp_aggregator->aggregator_identifier);
+				pr_debug("Port %d left LAG %d\n",
+					 port->actor_port_number,
+					 temp_aggregator->aggregator_identifier);
 				// if the aggregator is empty, clear its parameters, and set it ready to be attached
 				if (!temp_aggregator->lag_ports) {
 					ad_clear_agg(temp_aggregator);
@@ -1306,9 +1319,7 @@ static void ad_port_selection_logic(struct port *port)
 			}
 		}
 		if (!curr_port) { // meaning: the port was related to an aggregator but was not on the aggregator port list
-			pr_warning(DRV_NAME ": %s: Warning: Port %d (on %s) "
-				   "was related to aggregator %d but was not "
-				   "on its port list\n",
+			pr_warning("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
 				   port->slave->dev->master->name,
 				   port->actor_port_number,
 				   port->slave->dev->name,
@@ -1342,7 +1353,9 @@ static void ad_port_selection_logic(struct port *port)
 			port->next_port_in_aggregator=aggregator->lag_ports;
 			port->aggregator->num_of_ports++;
 			aggregator->lag_ports=port;
-			pr_debug("Port %d joined LAG %d(existing LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+			pr_debug("Port %d joined LAG %d(existing LAG)\n",
+				 port->actor_port_number,
+				 port->aggregator->aggregator_identifier);
 
 			// mark this port as selected
 			port->sm_vars |= AD_PORT_SELECTED;
@@ -1379,10 +1392,11 @@ static void ad_port_selection_logic(struct port *port)
 			// mark this port as selected
 			port->sm_vars |= AD_PORT_SELECTED;
 
-			pr_debug("Port %d joined LAG %d(new LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+			pr_debug("Port %d joined LAG %d(new LAG)\n",
+				 port->actor_port_number,
+				 port->aggregator->aggregator_identifier);
 		} else {
-			pr_err(DRV_NAME ": %s: Port %d (on %s) did not find "
-			       "a suitable aggregator\n",
+			pr_err("%s: Port %d (on %s) did not find a suitable aggregator\n",
 			       port->slave->dev->master->name,
 			       port->actor_port_number, port->slave->dev->name);
 		}
@@ -1459,8 +1473,7 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 		break;
 
 	default:
-		pr_warning(DRV_NAME
-			   ": %s: Impossible agg select mode %d\n",
+		pr_warning("%s: Impossible agg select mode %d\n",
 			   curr->slave->dev->master->name,
 			   __get_agg_selection_mode(curr->lag_ports));
 		break;
@@ -1545,40 +1558,38 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 	// if there is new best aggregator, activate it
 	if (best) {
 		pr_debug("best Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-		       best->aggregator_identifier, best->num_of_ports,
-		       best->actor_oper_aggregator_key,
-		       best->partner_oper_aggregator_key,
-		       best->is_individual, best->is_active);
+			 best->aggregator_identifier, best->num_of_ports,
+			 best->actor_oper_aggregator_key,
+			 best->partner_oper_aggregator_key,
+			 best->is_individual, best->is_active);
 		pr_debug("best ports %p slave %p %s\n",
-		       best->lag_ports, best->slave,
-		       best->slave ? best->slave->dev->name : "NULL");
+			 best->lag_ports, best->slave,
+			 best->slave ? best->slave->dev->name : "NULL");
 
 		for (agg = __get_first_agg(best->lag_ports); agg;
 		     agg = __get_next_agg(agg)) {
 
 			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-				agg->aggregator_identifier, agg->num_of_ports,
-				agg->actor_oper_aggregator_key,
-				agg->partner_oper_aggregator_key,
-				agg->is_individual, agg->is_active);
+				 agg->aggregator_identifier, agg->num_of_ports,
+				 agg->actor_oper_aggregator_key,
+				 agg->partner_oper_aggregator_key,
+				 agg->is_individual, agg->is_active);
 		}
 
 		// check if any partner replys
 		if (best->is_individual) {
-			pr_warning(DRV_NAME ": %s: Warning: No 802.3ad"
-			       " response from the link partner for any"
-			       " adapters in the bond\n",
-			       best->slave->dev->master->name);
+			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
+				   best->slave->dev->master->name);
 		}
 
 		best->is_active = 1;
 		pr_debug("LAG %d chosen as the active LAG\n",
-			best->aggregator_identifier);
+			 best->aggregator_identifier);
 		pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
-			best->aggregator_identifier, best->num_of_ports,
-			best->actor_oper_aggregator_key,
-			best->partner_oper_aggregator_key,
-			best->is_individual, best->is_active);
+			 best->aggregator_identifier, best->num_of_ports,
+			 best->actor_oper_aggregator_key,
+			 best->partner_oper_aggregator_key,
+			 best->is_individual, best->is_active);
 
 		// disable the ports that were related to the former active_aggregator
 		if (active) {
@@ -1632,7 +1643,8 @@ static void ad_clear_agg(struct aggregator *aggregator)
 		aggregator->lag_ports = NULL;
 		aggregator->is_active = 0;
 		aggregator->num_of_ports = 0;
-		pr_debug("LAG %d was cleared\n", aggregator->aggregator_identifier);
+		pr_debug("LAG %d was cleared\n",
+			 aggregator->aggregator_identifier);
 	}
 }
 
@@ -1727,7 +1739,9 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 static void ad_enable_collecting_distributing(struct port *port)
 {
 	if (port->aggregator->is_active) {
-		pr_debug("Enabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+		pr_debug("Enabling port %d(LAG %d)\n",
+			 port->actor_port_number,
+			 port->aggregator->aggregator_identifier);
 		__enable_port(port);
 	}
 }
@@ -1740,7 +1754,9 @@ static void ad_enable_collecting_distributing(struct port *port)
 static void ad_disable_collecting_distributing(struct port *port)
 {
 	if (port->aggregator && MAC_ADDRESS_COMPARE(&(port->aggregator->partner_system), &(null_mac_addr))) {
-		pr_debug("Disabling port %d(LAG %d)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
+		pr_debug("Disabling port %d(LAG %d)\n",
+			 port->actor_port_number,
+			 port->aggregator->aggregator_identifier);
 		__disable_port(port);
 	}
 }
@@ -1778,7 +1794,8 @@ static void ad_marker_info_send(struct port *port)
 
 	// send the marker information
 	if (ad_marker_send(port, &marker) >= 0) {
-		pr_debug("Sent Marker Information on port %d\n", port->actor_port_number);
+		pr_debug("Sent Marker Information on port %d\n",
+			 port->actor_port_number);
 	}
 }
 #endif
@@ -1802,7 +1819,8 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 	// send the marker response
 
 	if (ad_marker_send(port, &marker) >= 0) {
-		pr_debug("Sent Marker Response on port %d\n", port->actor_port_number);
+		pr_debug("Sent Marker Response on port %d\n",
+			 port->actor_port_number);
 	}
 }
 
@@ -1888,8 +1906,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 	struct aggregator *aggregator;
 
 	if (bond == NULL) {
-		pr_err(DRV_NAME ": %s: The slave %s is not attached to "
-		       "its bond\n",
+		pr_err("%s: The slave %s is not attached to its bond\n",
 		       slave->dev->master->name, slave->dev->name);
 		return -1;
 	}
@@ -1965,13 +1982,13 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		pr_warning(DRV_NAME ": Warning: %s: Trying to "
-			   "unbind an uninitialized port on %s\n",
+		pr_warning("Warning: %s: Trying to unbind an uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
-	pr_debug("Unbinding Link Aggregation Group %d\n", aggregator->aggregator_identifier);
+	pr_debug("Unbinding Link Aggregation Group %d\n",
+		 aggregator->aggregator_identifier);
 
 	/* Tell the partner that this port is not suitable for aggregation */
 	port->actor_oper_port_state &= ~AD_STATE_AGGREGATION;
@@ -1995,10 +2012,12 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			// if new aggregator found, copy the aggregator's parameters
 			// and connect the related lag_ports to the new aggregator
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
-				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n", aggregator->aggregator_identifier, new_aggregator->aggregator_identifier);
+				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n",
+					 aggregator->aggregator_identifier,
+					 new_aggregator->aggregator_identifier);
 
 				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
-					pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+					pr_info("%s: Removing an active aggregator\n",
 						aggregator->slave->dev->master->name);
 					// select new active aggregator
 					 select_new_active_agg = 1;
@@ -2029,8 +2048,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					ad_agg_selection_logic(__get_first_agg(port));
 				}
 			} else {
-				pr_warning(DRV_NAME ": %s: Warning: unbinding aggregator, "
-					   "and could not find a new aggregator for its ports\n",
+				pr_warning("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
 					   slave->dev->master->name);
 			}
 		} else { // in case that the only port related to this aggregator is the one we want to remove
@@ -2038,7 +2056,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			// clear the aggregator
 			ad_clear_agg(aggregator);
 			if (select_new_active_agg) {
-				pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+				pr_info("%s: Removing an active aggregator\n",
 					slave->dev->master->name);
 				// select new active aggregator
 				ad_agg_selection_logic(__get_first_agg(port));
@@ -2065,7 +2083,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					// clear the aggregator
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
-						pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+						pr_info("%s: Removing an active aggregator\n",
 							slave->dev->master->name);
 						// select new active aggregator
 						ad_agg_selection_logic(__get_first_agg(port));
@@ -2114,8 +2132,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		// select the active aggregator for the bond
 		if ((port = __get_first_port(bond))) {
 			if (!port->slave) {
-				pr_warning(DRV_NAME ": %s: Warning: bond's first port is "
-					   "uninitialized\n", bond->dev->name);
+				pr_warning("%s: Warning: bond's first port is uninitialized\n",
+					   bond->dev->name);
 				goto re_arm;
 			}
 
@@ -2128,8 +2146,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	// for each port run the state machines
 	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
 		if (!port->slave) {
-			pr_warning(DRV_NAME ": %s: Warning: Found an uninitialized "
-				   "port\n", bond->dev->name);
+			pr_warning("%s: Warning: Found an uninitialized port\n",
+				   bond->dev->name);
 			goto re_arm;
 		}
 
@@ -2170,15 +2188,15 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 		port = &(SLAVE_AD_INFO(slave).port);
 
 		if (!port->slave) {
-			pr_warning(DRV_NAME ": %s: Warning: port of slave %s "
-				   "is uninitialized\n",
+			pr_warning("%s: Warning: port of slave %s is uninitialized\n",
 				   slave->dev->name, slave->dev->master->name);
 			return;
 		}
 
 		switch (lacpdu->subtype) {
 		case AD_TYPE_LACPDU:
-			pr_debug("Received LACPDU on port %d\n", port->actor_port_number);
+			pr_debug("Received LACPDU on port %d\n",
+				 port->actor_port_number);
 			ad_rx_machine(lacpdu, port);
 			break;
 
@@ -2187,17 +2205,20 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 
 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
 			case AD_MARKER_INFORMATION_SUBTYPE:
-				pr_debug("Received Marker Information on port %d\n", port->actor_port_number);
+				pr_debug("Received Marker Information on port %d\n",
+					 port->actor_port_number);
 				ad_marker_info_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			case AD_MARKER_RESPONSE_SUBTYPE:
-				pr_debug("Received Marker Response on port %d\n", port->actor_port_number);
+				pr_debug("Received Marker Response on port %d\n",
+					 port->actor_port_number);
 				ad_marker_response_received((struct bond_marker *)lacpdu, port);
 				break;
 
 			default:
-				pr_debug("Received an unknown Marker subtype on slot %d\n", port->actor_port_number);
+				pr_debug("Received an unknown Marker subtype on slot %d\n",
+					 port->actor_port_number);
 			}
 		}
 	}
@@ -2217,8 +2238,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		pr_warning(DRV_NAME ": Warning: %s: speed "
-			   "changed for uninitialized port on %s\n",
+		pr_warning("Warning: %s: speed changed for uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
@@ -2245,8 +2265,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		pr_warning(DRV_NAME ": %s: Warning: duplex changed "
-			   "for uninitialized port on %s\n",
+		pr_warning("%s: Warning: duplex changed for uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
@@ -2274,8 +2293,7 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		pr_warning(DRV_NAME ": Warning: %s: link status changed for "
-			   "uninitialized port on %s\n",
+		pr_warning("Warning: %s: link status changed for uninitialized port on %s\n",
 			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
@@ -2380,8 +2398,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		pr_debug(DRV_NAME ": %s: Error: "
-			 "bond_3ad_get_active_agg_info failed\n", dev->name);
+		pr_debug("%s: Error: bond_3ad_get_active_agg_info failed\n",
+			 dev->name);
 		goto out;
 	}
 
@@ -2390,8 +2408,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	if (slaves_in_agg == 0) {
 		/*the aggregator is empty*/
-		pr_debug(DRV_NAME ": %s: Error: active aggregator is empty\n",
-			 dev->name);
+		pr_debug("%s: Error: active aggregator is empty\n", dev->name);
 		goto out;
 	}
 
@@ -2409,8 +2426,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (slave_agg_no >= 0) {
-		pr_err(DRV_NAME ": %s: Error: Couldn't find a slave to tx on "
-		       "for aggregator ID %d\n", dev->name, agg_id);
+		pr_err("%s: Error: Couldn't find a slave to tx on for aggregator ID %d\n",
+		       dev->name, agg_id);
 		goto out;
 	}
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9b5936f..2d39667 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -20,6 +20,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -201,8 +203,7 @@ static int tlb_initialize(struct bonding *bond)
 
 	new_hashtbl = kzalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
-		pr_err(DRV_NAME
-		       ": %s: Error: Failed to allocate TLB hash table\n",
+		pr_err("%s: Error: Failed to allocate TLB hash table\n",
 		       bond->dev->name);
 		return -1;
 	}
@@ -517,8 +518,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 				 client_info->slave->dev->dev_addr,
 				 client_info->mac_dst);
 		if (!skb) {
-			pr_err(DRV_NAME
-			       ": %s: Error: failed to create an ARP packet\n",
+			pr_err("%s: Error: failed to create an ARP packet\n",
 			       client_info->slave->dev->master->name);
 			continue;
 		}
@@ -528,8 +528,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 		if (client_info->tag) {
 			skb = vlan_put_tag(skb, client_info->vlan_id);
 			if (!skb) {
-				pr_err(DRV_NAME
-				       ": %s: Error: failed to insert VLAN tag\n",
+				pr_err("%s: Error: failed to insert VLAN tag\n",
 				       client_info->slave->dev->master->name);
 				continue;
 			}
@@ -612,9 +611,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if (!client_info->slave) {
-			pr_err(DRV_NAME
-			       ": %s: Error: found a client with no channel in "
-			       "the client's hash table\n",
+			pr_err("%s: Error: found a client with no channel in the client's hash table\n",
 			       bond->dev->name);
 			continue;
 		}
@@ -809,8 +806,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	new_hashtbl = kmalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
-		pr_err(DRV_NAME
-		       ": %s: Error: Failed to allocate RLB hash table\n",
+		pr_err("%s: Error: Failed to allocate RLB hash table\n",
 		       bond->dev->name);
 		return -1;
 	}
@@ -931,8 +927,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 
 			skb = vlan_put_tag(skb, vlan->vlan_id);
 			if (!skb) {
-				pr_err(DRV_NAME
-				       ": %s: Error: failed to insert VLAN tag\n",
+				pr_err("%s: Error: failed to insert VLAN tag\n",
 				       bond->dev->name);
 				continue;
 			}
@@ -961,11 +956,8 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
 	if (dev_set_mac_address(dev, &s_addr)) {
-		pr_err(DRV_NAME
-		       ": %s: Error: dev_set_mac_address of dev %s failed! ALB "
-		       "mode requires that the base driver support setting "
-		       "the hw address also when the network device's "
-		       "interface is open\n",
+		pr_err("%s: Error: dev_set_mac_address of dev %s failed!\n"
+		       "ALB mode requires that the base driver support setting the hw address also when the network device's interface is open\n",
 		       dev->master->name, dev->name);
 		return -EOPNOTSUPP;
 	}
@@ -1172,18 +1164,12 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr,
 				       bond->alb_info.rlb_enabled);
 
-		pr_warning(DRV_NAME
-			   ": %s: Warning: the hw address of slave %s is "
-			   "in use by the bond; giving it the hw address "
-			   "of %s\n",
+		pr_warning("%s: Warning: the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
 			   bond->dev->name, slave->dev->name,
 			   free_mac_slave->dev->name);
 
 	} else if (has_bond_addr) {
-		pr_err(DRV_NAME
-		       ": %s: Error: the hw address of slave %s is in use by the "
-		       "bond; couldn't find a slave with a free hw address to "
-		       "give it (this should not have happened)\n",
+		pr_err("%s: Error: the hw address of slave %s is in use by the bond; couldn't find a slave with a free hw address to give it (this should not have happened)\n",
 		       bond->dev->name, slave->dev->name);
 		return -EFAULT;
 	}
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 83921ab..c20b714 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -20,6 +20,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/if_vlan.h>
 #include <net/ipv6.h>
@@ -73,20 +75,20 @@ static void bond_na_send(struct net_device *slave_dev,
 	addrconf_addr_solict_mult(daddr, &mcaddr);
 
 	pr_debug("ipv6 na on slave %s: dest %pI6, src %pI6\n",
-	       slave_dev->name, &mcaddr, daddr);
+		 slave_dev->name, &mcaddr, daddr);
 
 	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
 			      ND_OPT_TARGET_LL_ADDR);
 
 	if (!skb) {
-		pr_err(DRV_NAME ": NA packet allocation failed\n");
+		pr_err("NA packet allocation failed\n");
 		return;
 	}
 
 	if (vlan_id) {
 		skb = vlan_put_tag(skb, vlan_id);
 		if (!skb) {
-			pr_err(DRV_NAME ": failed to insert VLAN tag\n");
+			pr_err("failed to insert VLAN tag\n");
 			return;
 		}
 	}
@@ -108,8 +110,8 @@ void bond_send_unsolicited_na(struct bonding *bond)
 	struct inet6_dev *idev;
 	int is_router;
 
-	pr_debug("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
-				slave ? slave->dev->name : "NULL");
+	pr_debug("%s: bond %s slave %s\n", bond->dev->name,
+		 __func__, slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_unsol_na ||
 	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69c5b15..ed09394 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -31,6 +31,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -247,7 +249,7 @@ static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
 	struct vlan_entry *vlan;
 
 	pr_debug("bond: %s, vlan id %d\n",
-		(bond ? bond->dev->name : "None"), vlan_id);
+		 (bond ? bond->dev->name : "None"), vlan_id);
 
 	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
 	if (!vlan)
@@ -290,8 +292,8 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 			if (bond_is_lb(bond))
 				bond_alb_clear_vlan(bond, vlan_id);
 
-			pr_debug("removed VLAN ID %d from bond %s\n", vlan_id,
-				bond->dev->name);
+			pr_debug("removed VLAN ID %d from bond %s\n",
+				 vlan_id, bond->dev->name);
 
 			kfree(vlan);
 
@@ -310,8 +312,8 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 		}
 	}
 
-	pr_debug("couldn't find VLAN ID %d in bond %s\n", vlan_id,
-		bond->dev->name);
+	pr_debug("couldn't find VLAN ID %d in bond %s\n",
+		 vlan_id, bond->dev->name);
 
 out:
 	write_unlock_bh(&bond->lock);
@@ -335,7 +337,7 @@ static int bond_has_challenged_slaves(struct bonding *bond)
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->dev->features & NETIF_F_VLAN_CHALLENGED) {
 			pr_debug("found VLAN challenged slave - %s\n",
-				slave->dev->name);
+				 slave->dev->name);
 			return 1;
 		}
 	}
@@ -486,8 +488,7 @@ static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
 
 	res = bond_add_vlan(bond, vid);
 	if (res) {
-		pr_err(DRV_NAME
-		       ": %s: Error: Failed to add vlan id %d\n",
+		pr_err("%s: Error: Failed to add vlan id %d\n",
 		       bond_dev->name, vid);
 	}
 }
@@ -521,8 +522,7 @@ static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 
 	res = bond_del_vlan(bond, vid);
 	if (res) {
-		pr_err(DRV_NAME
-		       ": %s: Error: Failed to remove vlan id %d\n",
+		pr_err("%s: Error: Failed to remove vlan id %d\n",
 		       bond_dev->name, vid);
 	}
 }
@@ -1040,8 +1040,7 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 		rv = dev_set_mac_address(new_active->dev, &saddr);
 		if (rv) {
-			pr_err(DRV_NAME
-			       ": %s: Error %d setting MAC of slave %s\n",
+			pr_err("%s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 			goto out;
 		}
@@ -1054,16 +1053,14 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 		rv = dev_set_mac_address(old_active->dev, &saddr);
 		if (rv)
-			pr_err(DRV_NAME
-			       ": %s: Error %d setting MAC of slave %s\n",
+			pr_err("%s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 out:
 		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
-		pr_err(DRV_NAME
-		       ": %s: bond_do_fail_over_mac impossible: bad policy %d\n",
+		pr_err("%s: bond_do_fail_over_mac impossible: bad policy %d\n",
 		       bond->dev->name, bond->params.fail_over_mac);
 		break;
 	}
@@ -1145,11 +1142,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
-				pr_info(DRV_NAME
-				       ": %s: making interface %s the new "
-				       "active one %d ms earlier.\n",
-				       bond->dev->name, new_active->dev->name,
-				       (bond->params.updelay - new_active->delay) * bond->params.miimon);
+				pr_info("%s: making interface %s the new active one %d ms earlier.\n",
+					bond->dev->name, new_active->dev->name,
+					(bond->params.updelay - new_active->delay) * bond->params.miimon);
 			}
 
 			new_active->delay = 0;
@@ -1162,10 +1157,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
 			if (USES_PRIMARY(bond->params.mode)) {
-				pr_info(DRV_NAME
-				       ": %s: making interface %s the new "
-				       "active one.\n",
-				       bond->dev->name, new_active->dev->name);
+				pr_info("%s: making interface %s the new active one.\n",
+					bond->dev->name, new_active->dev->name);
 			}
 		}
 	}
@@ -1235,13 +1228,11 @@ void bond_select_active_slave(struct bonding *bond)
 			return;
 
 		if (netif_carrier_ok(bond->dev)) {
-			pr_info(DRV_NAME
-			       ": %s: first active interface up!\n",
-			       bond->dev->name);
+			pr_info("%s: first active interface up!\n",
+				bond->dev->name);
 		} else {
-			pr_info(DRV_NAME ": %s: "
-			       "now running without any active interface !\n",
-			       bond->dev->name);
+			pr_info("%s: now running without any active interface !\n",
+				bond->dev->name);
 		}
 	}
 }
@@ -1390,16 +1381,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
 		slave_ops->ndo_do_ioctl == NULL) {
-		pr_warning(DRV_NAME
-		       ": %s: Warning: no link monitoring support for %s\n",
-		       bond_dev->name, slave_dev->name);
+		pr_warning("%s: Warning: no link monitoring support for %s\n",
+			   bond_dev->name, slave_dev->name);
 	}
 
 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		pr_warning(DRV_NAME
-			" %s: master_dev is not up in bond_enslave\n",
-			bond_dev->name);
+		pr_warning("%s: master_dev is not up in bond_enslave\n",
+			   bond_dev->name);
 	}
 
 	/* already enslaved */
@@ -1413,19 +1402,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
 		if (!list_empty(&bond->vlan_list)) {
-			pr_err(DRV_NAME
-			       ": %s: Error: cannot enslave VLAN "
-			       "challenged slave %s on VLAN enabled "
-			       "bond %s\n", bond_dev->name, slave_dev->name,
-			       bond_dev->name);
+			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
+			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
 		} else {
-			pr_warning(DRV_NAME
-			       ": %s: Warning: enslaved VLAN challenged "
-			       "slave %s. Adding VLANs will be blocked as "
-			       "long as %s is part of bond %s\n",
-			       bond_dev->name, slave_dev->name, slave_dev->name,
-			       bond_dev->name);
+			pr_warning("%s: Warning: enslaved VLAN challenged slave %s. Adding VLANs will be blocked as long as %s is part of bond %s\n",
+				   bond_dev->name, slave_dev->name,
+				   slave_dev->name, bond_dev->name);
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 		}
 	} else {
@@ -1445,8 +1428,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * enslaving it; the old ifenslave will not.
 	 */
 	if ((slave_dev->flags & IFF_UP)) {
-		pr_err(DRV_NAME ": %s is up. "
-		       "This may be due to an out of date ifenslave.\n",
+		pr_err("%s is up. This may be due to an out of date ifenslave.\n",
 		       slave_dev->name);
 		res = -EPERM;
 		goto err_undo_flags;
@@ -1462,7 +1444,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (bond->slave_cnt == 0) {
 		if (bond_dev->type != slave_dev->type) {
 			pr_debug("%s: change device type from %d to %d\n",
-				bond_dev->name, bond_dev->type, slave_dev->type);
+				 bond_dev->name,
+				 bond_dev->type, slave_dev->type);
 
 			netdev_bonding_change(bond_dev, NETDEV_BONDING_OLDTYPE);
 
@@ -1474,28 +1457,21 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			netdev_bonding_change(bond_dev, NETDEV_BONDING_NEWTYPE);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
-		pr_err(DRV_NAME ": %s ether type (%d) is different "
-			"from other slaves (%d), can not enslave it.\n",
-			slave_dev->name,
-			slave_dev->type, bond_dev->type);
-			res = -EINVAL;
-			goto err_undo_flags;
+		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it.\n",
+		       slave_dev->name,
+		       slave_dev->type, bond_dev->type);
+		res = -EINVAL;
+		goto err_undo_flags;
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
 		if (bond->slave_cnt == 0) {
-			pr_warning(DRV_NAME
-			       ": %s: Warning: The first slave device "
-			       "specified does not support setting the MAC "
-			       "address. Setting fail_over_mac to active.",
-			       bond_dev->name);
+			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
+				   bond_dev->name);
 			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
-			pr_err(DRV_NAME
-				": %s: Error: The slave device specified "
-				"does not support setting the MAC address, "
-				"but fail_over_mac is not set to active.\n"
-				, bond_dev->name);
+			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
+			       bond_dev->name);
 			res = -EOPNOTSUPP;
 			goto err_undo_flags;
 		}
@@ -1622,22 +1598,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			 * supported); thus, we don't need to change
 			 * the messages for netif_carrier.
 			 */
-			pr_warning(DRV_NAME
-			       ": %s: Warning: MII and ETHTOOL support not "
-			       "available for interface %s, and "
-			       "arp_interval/arp_ip_target module parameters "
-			       "not specified, thus bonding will not detect "
-			       "link failures! see bonding.txt for details.\n",
+			pr_warning("%s: Warning: MII and ETHTOOL support not available for interface %s, and arp_interval/arp_ip_target module parameters not specified, thus bonding will not detect link failures! see bonding.txt for details.\n",
 			       bond_dev->name, slave_dev->name);
 		} else if (link_reporting == -1) {
 			/* unable get link status using mii/ethtool */
-			pr_warning(DRV_NAME
-			       ": %s: Warning: can't get link status from "
-			       "interface %s; the network driver associated "
-			       "with this interface does not support MII or "
-			       "ETHTOOL link status reporting, thus miimon "
-			       "has no effect on this interface.\n",
-			       bond_dev->name, slave_dev->name);
+			pr_warning("%s: Warning: can't get link status from interface %s; the network driver associated with this interface does not support MII or ETHTOOL link status reporting, thus miimon has no effect on this interface.\n",
+				   bond_dev->name, slave_dev->name);
 		}
 	}
 
@@ -1645,34 +1611,27 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (!bond->params.miimon ||
 	    (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS)) {
 		if (bond->params.updelay) {
-			pr_debug("Initial state of slave_dev is "
-				"BOND_LINK_BACK\n");
+			pr_debug("Initial state of slave_dev is BOND_LINK_BACK\n");
 			new_slave->link  = BOND_LINK_BACK;
 			new_slave->delay = bond->params.updelay;
 		} else {
-			pr_debug("Initial state of slave_dev is "
-				"BOND_LINK_UP\n");
+			pr_debug("Initial state of slave_dev is BOND_LINK_UP\n");
 			new_slave->link  = BOND_LINK_UP;
 		}
 		new_slave->jiffies = jiffies;
 	} else {
-		pr_debug("Initial state of slave_dev is "
-			"BOND_LINK_DOWN\n");
+		pr_debug("Initial state of slave_dev is BOND_LINK_DOWN\n");
 		new_slave->link  = BOND_LINK_DOWN;
 	}
 
 	if (bond_update_speed_duplex(new_slave) &&
 	    (new_slave->link != BOND_LINK_DOWN)) {
-		pr_warning(DRV_NAME
-		       ": %s: Warning: failed to get speed and duplex from %s, "
-		       "assumed to be 100Mb/sec and Full.\n",
-		       bond_dev->name, new_slave->dev->name);
+		pr_warning("%s: Warning: failed to get speed and duplex from %s, assumed to be 100Mb/sec and Full.\n",
+			   bond_dev->name, new_slave->dev->name);
 
 		if (bond->params.mode == BOND_MODE_8023AD) {
-			pr_warning(DRV_NAME
-			       ": %s: Warning: Operation of 802.3ad mode requires ETHTOOL "
-			       "support in base driver for proper aggregator "
-			       "selection.\n", bond_dev->name);
+			pr_warning("%s: Warning: Operation of 802.3ad mode requires ETHTOOL support in base driver for proper aggregator selection.\n",
+				   bond_dev->name);
 		}
 	}
 
@@ -1742,11 +1701,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (res)
 		goto err_close;
 
-	pr_info(DRV_NAME
-	       ": %s: enslaving %s as a%s interface with a%s link.\n",
-	       bond_dev->name, slave_dev->name,
-	       new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
-	       new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
+	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
+		bond_dev->name, slave_dev->name,
+		new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
+		new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
 
 	/* enslave is successful */
 	return 0;
@@ -1798,8 +1756,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    (slave_dev->master != bond_dev)) {
-		pr_err(DRV_NAME
-		       ": %s: Error: cannot release %s.\n",
+		pr_err("%s: Error: cannot release %s.\n",
 		       bond_dev->name, slave_dev->name);
 		return -EINVAL;
 	}
@@ -1809,9 +1766,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	slave = bond_get_slave_by_dev(bond, slave_dev);
 	if (!slave) {
 		/* not a slave of this bond */
-		pr_info(DRV_NAME
-		       ": %s: %s not enslaved\n",
-		       bond_dev->name, slave_dev->name);
+		pr_info("%s: %s not enslaved\n",
+			bond_dev->name, slave_dev->name);
 		write_unlock_bh(&bond->lock);
 		return -EINVAL;
 	}
@@ -1819,14 +1775,10 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (!bond->params.fail_over_mac) {
 		if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr)
 		    && bond->slave_cnt > 1)
-			pr_warning(DRV_NAME
-			       ": %s: Warning: the permanent HWaddr of %s - "
-			       "%pM - is still in use by %s. "
-			       "Set the HWaddr of %s to a different address "
-			       "to avoid conflicts.\n",
-			       bond_dev->name, slave_dev->name,
-			       slave->perm_hwaddr,
-			       bond_dev->name, slave_dev->name);
+			pr_warning("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
+				   bond_dev->name, slave_dev->name,
+				   slave->perm_hwaddr,
+				   bond_dev->name, slave_dev->name);
 	}
 
 	/* Inform AD package of unbinding of slave. */
@@ -1837,12 +1789,10 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_3ad_unbind_slave(slave);
 	}
 
-	pr_info(DRV_NAME
-	       ": %s: releasing %s interface %s\n",
-	       bond_dev->name,
-	       (slave->state == BOND_STATE_ACTIVE)
-	       ? "active" : "backup",
-	       slave_dev->name);
+	pr_info("%s: releasing %s interface %s\n",
+		bond_dev->name,
+		(slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
+		slave_dev->name);
 
 	oldcurrent = bond->curr_active_slave;
 
@@ -1899,21 +1849,15 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		if (list_empty(&bond->vlan_list)) {
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 		} else {
-			pr_warning(DRV_NAME
-			       ": %s: Warning: clearing HW address of %s while it "
-			       "still has VLANs.\n",
-			       bond_dev->name, bond_dev->name);
-			pr_warning(DRV_NAME
-			       ": %s: When re-adding slaves, make sure the bond's "
-			       "HW address matches its VLANs'.\n",
-			       bond_dev->name);
+			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
+				   bond_dev->name, bond_dev->name);
+			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
+				   bond_dev->name);
 		}
 	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
 		   !bond_has_challenged_slaves(bond)) {
-		pr_info(DRV_NAME
-		       ": %s: last VLAN challenged slave %s "
-		       "left bond %s. VLAN blocking is removed\n",
-		       bond_dev->name, slave_dev->name, bond_dev->name);
+		pr_info("%s: last VLAN challenged slave %s left bond %s. VLAN blocking is removed\n",
+			bond_dev->name, slave_dev->name, bond_dev->name);
 		bond_dev->features &= ~NETIF_F_VLAN_CHALLENGED;
 	}
 
@@ -1995,8 +1939,8 @@ int  bond_release_and_destroy(struct net_device *bond_dev,
 
 	ret = bond_release(bond_dev, slave_dev);
 	if ((ret == 0) && (bond->slave_cnt == 0)) {
-		pr_info(DRV_NAME ": %s: destroying bond %s.\n",
-		       bond_dev->name, bond_dev->name);
+		pr_info("%s: destroying bond %s.\n",
+			bond_dev->name, bond_dev->name);
 		unregister_netdevice(bond_dev);
 	}
 	return ret;
@@ -2100,19 +2044,13 @@ static int bond_release_all(struct net_device *bond_dev)
 	if (list_empty(&bond->vlan_list))
 		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 	else {
-		pr_warning(DRV_NAME
-		       ": %s: Warning: clearing HW address of %s while it "
-		       "still has VLANs.\n",
-		       bond_dev->name, bond_dev->name);
-		pr_warning(DRV_NAME
-		       ": %s: When re-adding slaves, make sure the bond's "
-		       "HW address matches its VLANs'.\n",
-		       bond_dev->name);
+		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
+			   bond_dev->name, bond_dev->name);
+		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
+			   bond_dev->name);
 	}
 
-	pr_info(DRV_NAME
-	       ": %s: released all slaves\n",
-	       bond_dev->name);
+	pr_info("%s: released all slaves\n", bond_dev->name);
 
 out:
 	write_unlock_bh(&bond->lock);
@@ -2238,16 +2176,14 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
-				pr_info(DRV_NAME
-				       ": %s: link status down for %s"
-				       "interface %s, disabling it in %d ms.\n",
-				       bond->dev->name,
-				       (bond->params.mode ==
-					BOND_MODE_ACTIVEBACKUP) ?
-				       ((slave->state == BOND_STATE_ACTIVE) ?
-					"active " : "backup ") : "",
-				       slave->dev->name,
-				       bond->params.downdelay * bond->params.miimon);
+				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms.\n",
+					bond->dev->name,
+					(bond->params.mode ==
+					 BOND_MODE_ACTIVEBACKUP) ?
+					((slave->state == BOND_STATE_ACTIVE) ?
+					 "active " : "backup ") : "",
+					slave->dev->name,
+					bond->params.downdelay * bond->params.miimon);
 			}
 			/*FALLTHRU*/
 		case BOND_LINK_FAIL:
@@ -2257,13 +2193,11 @@ static int bond_miimon_inspect(struct bonding *bond)
 				 */
 				slave->link = BOND_LINK_UP;
 				slave->jiffies = jiffies;
-				pr_info(DRV_NAME
-				       ": %s: link status up again after %d "
-				       "ms for interface %s.\n",
-				       bond->dev->name,
-				       (bond->params.downdelay - slave->delay) *
-				       bond->params.miimon,
-				       slave->dev->name);
+				pr_info("%s: link status up again after %d ms for interface %s.\n",
+					bond->dev->name,
+					(bond->params.downdelay - slave->delay) *
+					bond->params.miimon,
+					slave->dev->name);
 				continue;
 			}
 
@@ -2284,25 +2218,21 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
-				pr_info(DRV_NAME
-				       ": %s: link status up for "
-				       "interface %s, enabling it in %d ms.\n",
-				       bond->dev->name, slave->dev->name,
-				       ignore_updelay ? 0 :
-				       bond->params.updelay *
-				       bond->params.miimon);
+				pr_info("%s: link status up for interface %s, enabling it in %d ms.\n",
+					bond->dev->name, slave->dev->name,
+					ignore_updelay ? 0 :
+					bond->params.updelay *
+					bond->params.miimon);
 			}
 			/*FALLTHRU*/
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				slave->link = BOND_LINK_DOWN;
-				pr_info(DRV_NAME
-				       ": %s: link status down again after %d "
-				       "ms for interface %s.\n",
-				       bond->dev->name,
-				       (bond->params.updelay - slave->delay) *
-				       bond->params.miimon,
-				       slave->dev->name);
+				pr_info("%s: link status down again after %d ms for interface %s.\n",
+					bond->dev->name,
+					(bond->params.updelay - slave->delay) *
+					bond->params.miimon,
+					slave->dev->name);
 
 				continue;
 			}
@@ -2350,10 +2280,8 @@ static void bond_miimon_commit(struct bonding *bond)
 				slave->state = BOND_STATE_BACKUP;
 			}
 
-			pr_info(DRV_NAME
-			       ": %s: link status definitely "
-			       "up for interface %s.\n",
-			       bond->dev->name, slave->dev->name);
+			pr_info("%s: link status definitely up for interface %s.\n",
+				bond->dev->name, slave->dev->name);
 
 			/* notify ad that the link status has changed */
 			if (bond->params.mode == BOND_MODE_8023AD)
@@ -2379,10 +2307,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			    bond->params.mode == BOND_MODE_8023AD)
 				bond_set_slave_inactive_flags(slave);
 
-			pr_info(DRV_NAME
-			       ": %s: link status definitely down for "
-			       "interface %s, disabling it\n",
-			       bond->dev->name, slave->dev->name);
+			pr_info("%s: link status definitely down for interface %s, disabling it\n",
+				bond->dev->name, slave->dev->name);
 
 			if (bond->params.mode == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave,
@@ -2398,8 +2324,7 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		default:
-			pr_err(DRV_NAME
-			       ": %s: invalid new link %d on slave %s\n",
+			pr_err("%s: invalid new link %d on slave %s\n",
 			       bond->dev->name, slave->new_link,
 			       slave->dev->name);
 			slave->new_link = BOND_LINK_NOCHANGE;
@@ -2518,19 +2443,19 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 	struct sk_buff *skb;
 
 	pr_debug("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
-	       slave_dev->name, dest_ip, src_ip, vlan_id);
+		 slave_dev->name, dest_ip, src_ip, vlan_id);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
 
 	if (!skb) {
-		pr_err(DRV_NAME ": ARP packet allocation failed\n");
+		pr_err("ARP packet allocation failed\n");
 		return;
 	}
 	if (vlan_id) {
 		skb = vlan_put_tag(skb, vlan_id);
 		if (!skb) {
-			pr_err(DRV_NAME ": failed to insert VLAN tag\n");
+			pr_err("failed to insert VLAN tag\n");
 			return;
 		}
 	}
@@ -2570,9 +2495,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		rv = ip_route_output_key(&init_net, &rt, &fl);
 		if (rv) {
 			if (net_ratelimit()) {
-				pr_warning(DRV_NAME
-			     ": %s: no route to arp_ip_target %pI4\n",
-				       bond->dev->name, &fl.fl4_dst);
+				pr_warning("%s: no route to arp_ip_target %pI4\n",
+					   bond->dev->name, &fl.fl4_dst);
 			}
 			continue;
 		}
@@ -2607,10 +2531,9 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 
 		if (net_ratelimit()) {
-			pr_warning(DRV_NAME
-	       ": %s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-			       bond->dev->name, &fl.fl4_dst,
-			       rt->u.dst.dev ? rt->u.dst.dev->name : "NULL");
+			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
+				   bond->dev->name, &fl.fl4_dst,
+				   rt->u.dst.dev ? rt->u.dst.dev->name : "NULL");
 		}
 		ip_rt_put(rt);
 	}
@@ -2628,8 +2551,8 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 
-	pr_debug("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
-				slave ? slave->dev->name : "NULL");
+	pr_debug("bond_send_grat_arp: bond %s slave %s\n",
+		 bond->dev->name, slave ? slave->dev->name : "NULL");
 
 	if (!slave || !bond->send_grat_arp ||
 	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
@@ -2658,7 +2581,8 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
 		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
-			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
+			 &sip, &tip, i, &targets[i],
+			 bond_has_this_ip(bond, tip));
 		if (sip == targets[i]) {
 			if (bond_has_this_ip(bond, tip))
 				slave->last_arp_rx = jiffies;
@@ -2685,8 +2609,8 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	read_lock(&bond->lock);
 
 	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
-		bond->dev->name, skb->dev ? skb->dev->name : "NULL",
-		orig_dev ? orig_dev->name : "NULL");
+		 bond->dev->name, skb->dev ? skb->dev->name : "NULL",
+		 orig_dev ? orig_dev->name : "NULL");
 
 	slave = bond_get_slave_by_dev(bond, orig_dev);
 	if (!slave || !slave_do_arp_validate(bond, slave))
@@ -2711,9 +2635,9 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	memcpy(&tip, arp_ptr, 4);
 
 	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
-		bond->dev->name, slave->dev->name, slave->state,
-		bond->params.arp_validate, slave_do_arp_validate(bond, slave),
-		&sip, &tip);
+		 bond->dev->name, slave->dev->name, slave->state,
+		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
+		 &sip, &tip);
 
 	/*
 	 * Backup slaves won't see the ARP reply, but do come through
@@ -2787,17 +2711,14 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 				 * is closed.
 				 */
 				if (!oldcurrent) {
-					pr_info(DRV_NAME
-					       ": %s: link status definitely "
-					       "up for interface %s, ",
-					       bond->dev->name,
-					       slave->dev->name);
+					pr_info("%s: link status definitely up for interface %s, ",
+						bond->dev->name,
+						slave->dev->name);
 					do_failover = 1;
 				} else {
-					pr_info(DRV_NAME
-					       ": %s: interface %s is now up\n",
-					       bond->dev->name,
-					       slave->dev->name);
+					pr_info("%s: interface %s is now up\n",
+						bond->dev->name,
+						slave->dev->name);
 				}
 			}
 		} else {
@@ -2816,10 +2737,9 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
 
-				pr_info(DRV_NAME
-				       ": %s: interface %s is now down.\n",
-				       bond->dev->name,
-				       slave->dev->name);
+				pr_info("%s: interface %s is now down.\n",
+					bond->dev->name,
+					slave->dev->name);
 
 				if (slave == oldcurrent)
 					do_failover = 1;
@@ -2952,9 +2872,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 				slave->link = BOND_LINK_UP;
 				bond->current_arp_slave = NULL;
 
-				pr_info(DRV_NAME
-					": %s: link status definitely "
-					"up for interface %s.\n",
+				pr_info("%s: link status definitely up for interface %s.\n",
 					bond->dev->name, slave->dev->name);
 
 				if (!bond->curr_active_slave ||
@@ -2972,9 +2890,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			slave->link = BOND_LINK_DOWN;
 			bond_set_slave_inactive_flags(slave);
 
-			pr_info(DRV_NAME
-				": %s: link status definitely down for "
-				"interface %s, disabling it\n",
+			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
 
 			if (slave == bond->curr_active_slave) {
@@ -2985,8 +2901,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			continue;
 
 		default:
-			pr_err(DRV_NAME
-			       ": %s: impossible: new_link %d on slave %s\n",
+			pr_err("%s: impossible: new_link %d on slave %s\n",
 			       bond->dev->name, slave->new_link,
 			       slave->dev->name);
 			continue;
@@ -3015,9 +2930,9 @@ static void bond_ab_arp_probe(struct bonding *bond)
 	read_lock(&bond->curr_slave_lock);
 
 	if (bond->current_arp_slave && bond->curr_active_slave)
-		pr_info(DRV_NAME "PROBE: c_arp %s && cas %s BAD\n",
-		       bond->current_arp_slave->dev->name,
-		       bond->curr_active_slave->dev->name);
+		pr_info("PROBE: c_arp %s && cas %s BAD\n",
+			bond->current_arp_slave->dev->name,
+			bond->curr_active_slave->dev->name);
 
 	if (bond->curr_active_slave) {
 		bond_arp_send_all(bond, bond->curr_active_slave);
@@ -3065,9 +2980,8 @@ static void bond_ab_arp_probe(struct bonding *bond)
 
 			bond_set_slave_inactive_flags(slave);
 
-			pr_info(DRV_NAME
-			       ": %s: backup interface %s is now down.\n",
-			       bond->dev->name, slave->dev->name);
+			pr_info("%s: backup interface %s is now down.\n",
+				bond->dev->name, slave->dev->name);
 		}
 	}
 }
@@ -3343,9 +3257,8 @@ static int bond_create_proc_entry(struct bonding *bond)
 						    S_IRUGO, bond_proc_dir,
 						    &bond_info_fops, bond);
 		if (bond->proc_entry == NULL)
-			pr_warning(DRV_NAME
-			       ": Warning: Cannot create /proc/net/%s/%s\n",
-			       DRV_NAME, bond_dev->name);
+			pr_warning("Warning: Cannot create /proc/net/%s/%s\n",
+				   DRV_NAME, bond_dev->name);
 		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
 	}
@@ -3370,9 +3283,8 @@ static void bond_create_proc_dir(void)
 	if (!bond_proc_dir) {
 		bond_proc_dir = proc_mkdir(DRV_NAME, init_net.proc_net);
 		if (!bond_proc_dir)
-			pr_warning(DRV_NAME
-				": Warning: cannot create /proc/net/%s\n",
-				DRV_NAME);
+			pr_warning("Warning: cannot create /proc/net/%s\n",
+				   DRV_NAME);
 	}
 }
 
@@ -3530,8 +3442,8 @@ static int bond_netdev_event(struct notifier_block *this,
 		return NOTIFY_DONE;
 
 	pr_debug("event_dev: %s, event: %lx\n",
-		(event_dev ? event_dev->name : "None"),
-		event);
+		 event_dev ? event_dev->name : "None",
+		 event);
 
 	if (!(event_dev->priv_flags & IFF_BONDING))
 		return NOTIFY_DONE;
@@ -3871,8 +3783,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	struct mii_ioctl_data *mii = NULL;
 	int res = 0;
 
-	pr_debug("bond_ioctl: master=%s, cmd=%d\n",
-		bond_dev->name, cmd);
+	pr_debug("bond_ioctl: master=%s, cmd=%d\n", bond_dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -3941,12 +3852,12 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 	slave_dev = dev_get_by_name(&init_net, ifr->ifr_slave);
 
-	pr_debug("slave_dev=%p: \n", slave_dev);
+	pr_debug("slave_dev=%p:\n", slave_dev);
 
 	if (!slave_dev)
 		res = -ENODEV;
 	else {
-		pr_debug("slave_dev->name=%s: \n", slave_dev->name);
+		pr_debug("slave_dev->name=%s:\n", slave_dev->name);
 		switch (cmd) {
 		case BOND_ENSLAVE_OLD:
 		case SIOCBONDENSLAVE:
@@ -4055,7 +3966,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	int i;
 
 	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
-		(bond_dev ? bond_dev->name : "None"), new_mtu);
+		 (bond_dev ? bond_dev->name : "None"), new_mtu);
 
 	/* Can't hold bond->lock with bh disabled here since
 	 * some base drivers panic. On the other hand we can't
@@ -4073,8 +3984,10 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	 */
 
 	bond_for_each_slave(bond, slave, i) {
-		pr_debug("s %p s->p %p c_m %p\n", slave,
-			slave->prev, slave->dev->netdev_ops->ndo_change_mtu);
+		pr_debug("s %p s->p %p c_m %p\n",
+			 slave,
+			 slave->prev,
+			 slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
 
@@ -4104,8 +4017,8 @@ unwind:
 
 		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
 		if (tmp_res) {
-			pr_debug("unwind err %d dev %s\n", tmp_res,
-				slave->dev->name);
+			pr_debug("unwind err %d dev %s\n",
+				 tmp_res, slave->dev->name);
 		}
 	}
 
@@ -4131,7 +4044,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 		return bond_alb_set_mac_address(bond_dev, addr);
 
 
-	pr_debug("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
+	pr_debug("bond=%p, name=%s\n",
+		 bond, bond_dev ? bond_dev->name : "None");
 
 	/*
 	 * If fail_over_mac is set to active, do nothing and return
@@ -4196,8 +4110,8 @@ unwind:
 
 		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
 		if (tmp_res) {
-			pr_debug("unwind err %d dev %s\n", tmp_res,
-				slave->dev->name);
+			pr_debug("unwind err %d dev %s\n",
+				 tmp_res, slave->dev->name);
 		}
 	}
 
@@ -4353,9 +4267,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 			if (tx_dev) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (!skb2) {
-					pr_err(DRV_NAME
-					       ": %s: Error: bond_xmit_broadcast(): "
-					       "skb_clone() failed\n",
+					pr_err("%s: Error: bond_xmit_broadcast(): skb_clone() failed\n",
 					       bond_dev->name);
 					continue;
 				}
@@ -4421,8 +4333,8 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return bond_alb_xmit(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
-		pr_err(DRV_NAME ": %s: Error: Unknown bonding mode %d\n",
-		     dev->name, bond->params.mode);
+		pr_err("%s: Error: Unknown bonding mode %d\n",
+		       dev->name, bond->params.mode);
 		WARN_ON_ONCE(1);
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -4458,10 +4370,8 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		break;
 	default:
 		/* Should never happen, mode already checked */
-		pr_err(DRV_NAME
-		       ": %s: Error: Unknown bonding mode %d\n",
-		       bond_dev->name,
-		       mode);
+		pr_err("%s: Error: Unknown bonding mode %d\n",
+		       bond_dev->name, mode);
 		break;
 	}
 }
@@ -4654,8 +4564,7 @@ static int bond_check_params(struct bond_params *params)
 	if (mode) {
 		bond_mode = bond_parse_parm(mode, bond_mode_tbl);
 		if (bond_mode == -1) {
-			pr_err(DRV_NAME
-			       ": Error: Invalid bonding mode \"%s\"\n",
+			pr_err("Error: Invalid bonding mode \"%s\"\n",
 			       mode == NULL ? "NULL" : mode);
 			return -EINVAL;
 		}
@@ -4664,15 +4573,13 @@ static int bond_check_params(struct bond_params *params)
 	if (xmit_hash_policy) {
 		if ((bond_mode != BOND_MODE_XOR) &&
 		    (bond_mode != BOND_MODE_8023AD)) {
-			pr_info(DRV_NAME
-			       ": xor_mode param is irrelevant in mode %s\n",
-			       bond_mode_name(bond_mode));
+			pr_info("xor_mode param is irrelevant in mode %s\n",
+				bond_mode_name(bond_mode));
 		} else {
 			xmit_hashtype = bond_parse_parm(xmit_hash_policy,
 							xmit_hashtype_tbl);
 			if (xmit_hashtype == -1) {
-				pr_err(DRV_NAME
-				       ": Error: Invalid xmit_hash_policy \"%s\"\n",
+				pr_err("Error: Invalid xmit_hash_policy \"%s\"\n",
 				       xmit_hash_policy == NULL ? "NULL" :
 				       xmit_hash_policy);
 				return -EINVAL;
@@ -4682,14 +4589,12 @@ static int bond_check_params(struct bond_params *params)
 
 	if (lacp_rate) {
 		if (bond_mode != BOND_MODE_8023AD) {
-			pr_info(DRV_NAME
-			       ": lacp_rate param is irrelevant in mode %s\n",
-			       bond_mode_name(bond_mode));
+			pr_info("lacp_rate param is irrelevant in mode %s\n",
+				bond_mode_name(bond_mode));
 		} else {
 			lacp_fast = bond_parse_parm(lacp_rate, bond_lacp_tbl);
 			if (lacp_fast == -1) {
-				pr_err(DRV_NAME
-				       ": Error: Invalid lacp rate \"%s\"\n",
+				pr_err("Error: Invalid lacp rate \"%s\"\n",
 				       lacp_rate == NULL ? "NULL" : lacp_rate);
 				return -EINVAL;
 			}
@@ -4699,82 +4604,64 @@ static int bond_check_params(struct bond_params *params)
 	if (ad_select) {
 		params->ad_select = bond_parse_parm(ad_select, ad_select_tbl);
 		if (params->ad_select == -1) {
-			pr_err(DRV_NAME
-			       ": Error: Invalid ad_select \"%s\"\n",
+			pr_err("Error: Invalid ad_select \"%s\"\n",
 			       ad_select == NULL ? "NULL" : ad_select);
 			return -EINVAL;
 		}
 
 		if (bond_mode != BOND_MODE_8023AD) {
-			pr_warning(DRV_NAME
-			       ": ad_select param only affects 802.3ad mode\n");
+			pr_warning("ad_select param only affects 802.3ad mode\n");
 		}
 	} else {
 		params->ad_select = BOND_AD_STABLE;
 	}
 
 	if (max_bonds < 0) {
-		pr_warning(DRV_NAME
-		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
-		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
-		       max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
+		pr_warning("Warning: max_bonds (%d) not in range %d-%d, so it was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
+			   max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
 
 	if (miimon < 0) {
-		pr_warning(DRV_NAME
-		       ": Warning: miimon module parameter (%d), "
-		       "not in range 0-%d, so it was reset to %d\n",
-		       miimon, INT_MAX, BOND_LINK_MON_INTERV);
+		pr_warning("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to %d\n",
+			   miimon, INT_MAX, BOND_LINK_MON_INTERV);
 		miimon = BOND_LINK_MON_INTERV;
 	}
 
 	if (updelay < 0) {
-		pr_warning(DRV_NAME
-		       ": Warning: updelay module parameter (%d), "
-		       "not in range 0-%d, so it was reset to 0\n",
-		       updelay, INT_MAX);
+		pr_warning("Warning: updelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			   updelay, INT_MAX);
 		updelay = 0;
 	}
 
 	if (downdelay < 0) {
-		pr_warning(DRV_NAME
-		       ": Warning: downdelay module parameter (%d), "
-		       "not in range 0-%d, so it was reset to 0\n",
-		       downdelay, INT_MAX);
+		pr_warning("Warning: downdelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			   downdelay, INT_MAX);
 		downdelay = 0;
 	}
 
 	if ((use_carrier != 0) && (use_carrier != 1)) {
-		pr_warning(DRV_NAME
-		       ": Warning: use_carrier module parameter (%d), "
-		       "not of valid value (0/1), so it was set to 1\n",
-		       use_carrier);
+		pr_warning("Warning: use_carrier module parameter (%d), not of valid value (0/1), so it was set to 1\n",
+			   use_carrier);
 		use_carrier = 1;
 	}
 
 	if (num_grat_arp < 0 || num_grat_arp > 255) {
-		pr_warning(DRV_NAME
-		       ": Warning: num_grat_arp (%d) not in range 0-255 so it "
-		       "was reset to 1 \n", num_grat_arp);
+		pr_warning("Warning: num_grat_arp (%d) not in range 0-255 so it was reset to 1 \n",
+			   num_grat_arp);
 		num_grat_arp = 1;
 	}
 
 	if (num_unsol_na < 0 || num_unsol_na > 255) {
-		pr_warning(DRV_NAME
-		       ": Warning: num_unsol_na (%d) not in range 0-255 so it "
-		       "was reset to 1 \n", num_unsol_na);
+		pr_warning("Warning: num_unsol_na (%d) not in range 0-255 so it was reset to 1 \n",
+			   num_unsol_na);
 		num_unsol_na = 1;
 	}
 
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
-			pr_warning(DRV_NAME
-			       ": Warning: miimon must be specified, "
-			       "otherwise bonding will not detect link "
-			       "failure, speed and duplex which are "
-			       "essential for 802.3ad operation\n");
+			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
 			pr_warning("Forcing miimon to 100msec\n");
 			miimon = 100;
 		}
@@ -4784,24 +4671,15 @@ static int bond_check_params(struct bond_params *params)
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
 		if (!miimon) {
-			pr_warning(DRV_NAME
-			       ": Warning: miimon must be specified, "
-			       "otherwise bonding will not detect link "
-			       "failure and link speed which are essential "
-			       "for TLB/ALB load balancing\n");
+			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure and link speed which are essential for TLB/ALB load balancing\n");
 			pr_warning("Forcing miimon to 100msec\n");
 			miimon = 100;
 		}
 	}
 
 	if (bond_mode == BOND_MODE_ALB) {
-		pr_notice(DRV_NAME
-		       ": In ALB mode you might experience client "
-		       "disconnections upon reconnection of a link if the "
-		       "bonding module updelay parameter (%d msec) is "
-		       "incompatible with the forwarding delay time of the "
-		       "switch\n",
-		       updelay);
+		pr_notice("In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (%d msec) is incompatible with the forwarding delay time of the switch\n",
+			  updelay);
 	}
 
 	if (!miimon) {
@@ -4809,49 +4687,37 @@ static int bond_check_params(struct bond_params *params)
 			/* just warn the user the up/down delay will have
 			 * no effect since miimon is zero...
 			 */
-			pr_warning(DRV_NAME
-			       ": Warning: miimon module parameter not set "
-			       "and updelay (%d) or downdelay (%d) module "
-			       "parameter is set; updelay and downdelay have "
-			       "no effect unless miimon is set\n",
-			       updelay, downdelay);
+			pr_warning("Warning: miimon module parameter not set and updelay (%d) or downdelay (%d) module parameter is set; updelay and downdelay have no effect unless miimon is set\n",
+				   updelay, downdelay);
 		}
 	} else {
 		/* don't allow arp monitoring */
 		if (arp_interval) {
-			pr_warning(DRV_NAME
-			       ": Warning: miimon (%d) and arp_interval (%d) "
-			       "can't be used simultaneously, disabling ARP "
-			       "monitoring\n",
-			       miimon, arp_interval);
+			pr_warning("Warning: miimon (%d) and arp_interval (%d) can't be used simultaneously, disabling ARP monitoring\n",
+				   miimon, arp_interval);
 			arp_interval = 0;
 		}
 
 		if ((updelay % miimon) != 0) {
-			pr_warning(DRV_NAME
-			       ": Warning: updelay (%d) is not a multiple "
-			       "of miimon (%d), updelay rounded to %d ms\n",
-			       updelay, miimon, (updelay / miimon) * miimon);
+			pr_warning("Warning: updelay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
+				   updelay, miimon,
+				   (updelay / miimon) * miimon);
 		}
 
 		updelay /= miimon;
 
 		if ((downdelay % miimon) != 0) {
-			pr_warning(DRV_NAME
-			       ": Warning: downdelay (%d) is not a multiple "
-			       "of miimon (%d), downdelay rounded to %d ms\n",
-			       downdelay, miimon,
-			       (downdelay / miimon) * miimon);
+			pr_warning("Warning: downdelay (%d) is not a multiple of miimon (%d), downdelay rounded to %d ms\n",
+				   downdelay, miimon,
+				   (downdelay / miimon) * miimon);
 		}
 
 		downdelay /= miimon;
 	}
 
 	if (arp_interval < 0) {
-		pr_warning(DRV_NAME
-		       ": Warning: arp_interval module parameter (%d) "
-		       ", not in range 0-%d, so it was reset to %d\n",
-		       arp_interval, INT_MAX, BOND_LINK_ARP_INTERV);
+		pr_warning("Warning: arp_interval module parameter (%d) , not in range 0-%d, so it was reset to %d\n",
+			   arp_interval, INT_MAX, BOND_LINK_ARP_INTERV);
 		arp_interval = BOND_LINK_ARP_INTERV;
 	}
 
@@ -4861,10 +4727,8 @@ static int bond_check_params(struct bond_params *params)
 		/* not complete check, but should be good enough to
 		   catch mistakes */
 		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
-			pr_warning(DRV_NAME
-			       ": Warning: bad arp_ip_target module parameter "
-			       "(%s), ARP monitoring will not be performed\n",
-			       arp_ip_target[arp_ip_count]);
+			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
+				   arp_ip_target[arp_ip_count]);
 			arp_interval = 0;
 		} else {
 			__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
@@ -4874,31 +4738,25 @@ static int bond_check_params(struct bond_params *params)
 
 	if (arp_interval && !arp_ip_count) {
 		/* don't allow arping if no arp_ip_target given... */
-		pr_warning(DRV_NAME
-		       ": Warning: arp_interval module parameter (%d) "
-		       "specified without providing an arp_ip_target "
-		       "parameter, arp_interval was reset to 0\n",
-		       arp_interval);
+		pr_warning("Warning: arp_interval module parameter (%d) specified without providing an arp_ip_target parameter, arp_interval was reset to 0\n",
+			   arp_interval);
 		arp_interval = 0;
 	}
 
 	if (arp_validate) {
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
-			pr_err(DRV_NAME
-			       ": arp_validate only supported in active-backup mode\n");
+			pr_err("arp_validate only supported in active-backup mode\n");
 			return -EINVAL;
 		}
 		if (!arp_interval) {
-			pr_err(DRV_NAME
-			       ": arp_validate requires arp_interval\n");
+			pr_err("arp_validate requires arp_interval\n");
 			return -EINVAL;
 		}
 
 		arp_validate_value = bond_parse_parm(arp_validate,
 						     arp_validate_tbl);
 		if (arp_validate_value == -1) {
-			pr_err(DRV_NAME
-			       ": Error: invalid arp_validate \"%s\"\n",
+			pr_err("Error: invalid arp_validate \"%s\"\n",
 			       arp_validate == NULL ? "NULL" : arp_validate);
 			return -EINVAL;
 		}
@@ -4906,17 +4764,14 @@ static int bond_check_params(struct bond_params *params)
 		arp_validate_value = 0;
 
 	if (miimon) {
-		pr_info(DRV_NAME
-		       ": MII link monitoring set to %d ms\n",
-		       miimon);
+		pr_info("MII link monitoring set to %d ms\n", miimon);
 	} else if (arp_interval) {
 		int i;
 
-		pr_info(DRV_NAME ": ARP monitoring set to %d ms,"
-		       " validate %s, with %d target(s):",
-		       arp_interval,
-		       arp_validate_tbl[arp_validate_value].modename,
-		       arp_ip_count);
+		pr_info("ARP monitoring set to %d ms, validate %s, with %d target(s):",
+			arp_interval,
+			arp_validate_tbl[arp_validate_value].modename,
+			arp_ip_count);
 
 		for (i = 0; i < arp_ip_count; i++)
 			pr_info(" %s", arp_ip_target[i]);
@@ -4927,21 +4782,15 @@ static int bond_check_params(struct bond_params *params)
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
-		pr_warning(DRV_NAME
-		       ": Warning: either miimon or arp_interval and "
-		       "arp_ip_target module parameters must be specified, "
-		       "otherwise bonding will not detect link failures! see "
-		       "bonding.txt for details.\n");
+		pr_warning("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
 	}
 
 	if (primary && !USES_PRIMARY(bond_mode)) {
 		/* currently, using a primary only makes sense
 		 * in active backup, TLB or ALB modes
 		 */
-		pr_warning(DRV_NAME
-		       ": Warning: %s primary device specified but has no "
-		       "effect in %s mode\n",
-		       primary, bond_mode_name(bond_mode));
+		pr_warning("Warning: %s primary device specified but has no effect in %s mode\n",
+			   primary, bond_mode_name(bond_mode));
 		primary = NULL;
 	}
 
@@ -4949,16 +4798,13 @@ static int bond_check_params(struct bond_params *params)
 		fail_over_mac_value = bond_parse_parm(fail_over_mac,
 						      fail_over_mac_tbl);
 		if (fail_over_mac_value == -1) {
-			pr_err(DRV_NAME
-			       ": Error: invalid fail_over_mac \"%s\"\n",
+			pr_err("Error: invalid fail_over_mac \"%s\"\n",
 			       arp_validate == NULL ? "NULL" : arp_validate);
 			return -EINVAL;
 		}
 
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
-			pr_warning(DRV_NAME
-			       ": Warning: fail_over_mac only affects "
-			       "active-backup mode.\n");
+			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
 	} else {
 		fail_over_mac_value = BOND_FOM_NONE;
 	}
@@ -5043,8 +4889,7 @@ int bond_create(const char *name)
 	/* Check to see if the bond already exists. */
 	/* FIXME: pass netns from caller */
 	if (name && __dev_get_by_name(&init_net, name)) {
-		pr_err(DRV_NAME ": cannot add bond %s; already exists\n",
-		       name);
+		pr_err("cannot add bond %s; already exists\n", name);
 		res = -EEXIST;
 		goto out_rtnl;
 	}
@@ -5052,8 +4897,7 @@ int bond_create(const char *name)
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				bond_setup);
 	if (!bond_dev) {
-		pr_err(DRV_NAME ": %s: eek! can't alloc netdev!\n",
-		       name);
+		pr_err("%s: eek! can't alloc netdev!\n", name);
 		res = -ENOMEM;
 		goto out_rtnl;
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ff449de..f84c3d9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -19,6 +19,9 @@
  * file called LICENSE.
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -102,11 +105,10 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		goto err_no_cmd;
 
 	if (command[0] == '+') {
-		pr_info(DRV_NAME
-			": %s is being created...\n", ifname);
+		pr_info("%s is being created...\n", ifname);
 		rv = bond_create(ifname);
 		if (rv) {
-			pr_info(DRV_NAME ": Bond creation failed.\n");
+			pr_info("Bond creation failed.\n");
 			res = rv;
 		}
 	} else if (command[0] == '-') {
@@ -115,12 +117,10 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		rtnl_lock();
 		bond_dev = bond_get_by_name(ifname);
 		if (bond_dev) {
-			pr_info(DRV_NAME ": %s is being deleted...\n",
-				ifname);
+			pr_info("%s is being deleted...\n", ifname);
 			unregister_netdevice(bond_dev);
 		} else {
-			pr_err(DRV_NAME ": unable to delete non-existent %s\n",
-			       ifname);
+			pr_err("unable to delete non-existent %s\n", ifname);
 			res = -ENODEV;
 		}
 		rtnl_unlock();
@@ -133,8 +133,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
 	return res;
 
 err_no_cmd:
-	pr_err(DRV_NAME ": no command found in bonding_masters."
-	       " Use +ifname or -ifname.\n");
+	pr_err("no command found in bonding_masters. Use +ifname or -ifname.\n");
 	return -EPERM;
 }
 
@@ -218,8 +217,8 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	/* Quick sanity check -- is the bond interface up? */
 	if (!(bond->dev->flags & IFF_UP)) {
-		pr_warning(DRV_NAME ": %s: doing slave updates when "
-			   "interface is down.\n", bond->dev->name);
+		pr_warning("%s: doing slave updates when interface is down.\n",
+			   bond->dev->name);
 	}
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
@@ -241,17 +240,14 @@ static ssize_t bonding_store_slaves(struct device *d,
 		/* FIXME: get netns from sysfs object */
 		dev = __dev_get_by_name(&init_net, ifname);
 		if (!dev) {
-			pr_info(DRV_NAME
-			       ": %s: Interface %s does not exist!\n",
-			       bond->dev->name, ifname);
+			pr_info("%s: Interface %s does not exist!\n",
+				bond->dev->name, ifname);
 			ret = -ENODEV;
 			goto out;
 		}
 
 		if (dev->flags & IFF_UP) {
-			pr_err(DRV_NAME
-			       ": %s: Error: Unable to enslave %s "
-			       "because it is already up.\n",
+			pr_err("%s: Error: Unable to enslave %s because it is already up.\n",
 			       bond->dev->name, dev->name);
 			ret = -EPERM;
 			goto out;
@@ -260,8 +256,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, i)
 			if (slave->dev == dev) {
-				pr_err(DRV_NAME
-				       ": %s: Interface %s is already enslaved!\n",
+				pr_err("%s: Interface %s is already enslaved!\n",
 				       bond->dev->name, ifname);
 				ret = -EPERM;
 				read_unlock(&bond->lock);
@@ -269,8 +264,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 			}
 		read_unlock(&bond->lock);
 
-		pr_info(DRV_NAME ": %s: Adding slave %s.\n",
-			bond->dev->name, ifname);
+		pr_info("%s: Adding slave %s.\n", bond->dev->name, ifname);
 
 		/* If this is the first slave, then we need to set
 		   the master's hardware address to be the same as the
@@ -307,7 +301,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 				break;
 			}
 		if (dev) {
-			pr_info(DRV_NAME ": %s: Removing slave %s\n",
+			pr_info("%s: Removing slave %s\n",
 				bond->dev->name, dev->name);
 				res = bond_release(bond->dev, dev);
 			if (res) {
@@ -317,16 +311,16 @@ static ssize_t bonding_store_slaves(struct device *d,
 			/* set the slave MTU to the default */
 			dev_set_mtu(dev, original_mtu);
 		} else {
-			pr_err(DRV_NAME ": unable to remove non-existent"
-			       " slave %s for bond %s.\n",
-				ifname, bond->dev->name);
+			pr_err("unable to remove non-existent slave %s for bond %s.\n",
+			       ifname, bond->dev->name);
 			ret = -ENODEV;
 		}
 		goto out;
 	}
 
 err_no_cmd:
-	pr_err(DRV_NAME ": no command found in slaves file for bond %s. Use +ifname or -ifname.\n", bond->dev->name);
+	pr_err("no command found in slaves file for bond %s. Use +ifname or -ifname.\n",
+	       bond->dev->name);
 	ret = -EPERM;
 
 out:
@@ -359,18 +353,16 @@ static ssize_t bonding_store_mode(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		pr_err(DRV_NAME ": unable to update mode of %s"
-		       " because interface is up.\n", bond->dev->name);
+		pr_err("unable to update mode of %s because interface is up.\n",
+		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
 
 	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid mode value %.*s.\n",
-		       bond->dev->name,
-		       (int)strlen(buf) - 1, buf);
+		pr_err("%s: Ignoring invalid mode value %.*s.\n",
+		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
 		goto out;
 	} else {
@@ -382,8 +374,8 @@ static ssize_t bonding_store_mode(struct device *d,
 
 		bond->params.mode = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
-		pr_info(DRV_NAME ": %s: setting mode to %s (%d).\n",
-		       bond->dev->name, bond_mode_tbl[new_value].modename,
+		pr_info("%s: setting mode to %s (%d).\n",
+			bond->dev->name, bond_mode_tbl[new_value].modename,
 		       new_value);
 	}
 out:
@@ -415,8 +407,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		pr_err(DRV_NAME
-		       "%s: Interface is up. Unable to update xmit policy.\n",
+		pr_err("%s: Interface is up. Unable to update xmit policy.\n",
 		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
@@ -424,8 +415,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 
 	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid xmit hash policy value %.*s.\n",
+		pr_err("%s: Ignoring invalid xmit hash policy value %.*s.\n",
 		       bond->dev->name,
 		       (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
@@ -433,7 +423,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 	} else {
 		bond->params.xmit_policy = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
-		pr_info(DRV_NAME ": %s: setting xmit hash policy to %s (%d).\n",
+		pr_info("%s: setting xmit hash policy to %s (%d).\n",
 			bond->dev->name,
 			xmit_hashtype_tbl[new_value].modename, new_value);
 	}
@@ -466,20 +456,18 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 
 	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid arp_validate value %s\n",
+		pr_err("%s: Ignoring invalid arp_validate value %s\n",
 		       bond->dev->name, buf);
 		return -EINVAL;
 	}
 	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
-		pr_err(DRV_NAME
-		       ": %s: arp_validate only supported in active-backup mode.\n",
+		pr_err("%s: arp_validate only supported in active-backup mode.\n",
 		       bond->dev->name);
 		return -EINVAL;
 	}
-	pr_info(DRV_NAME ": %s: setting arp_validate to %s (%d).\n",
-	       bond->dev->name, arp_validate_tbl[new_value].modename,
-	       new_value);
+	pr_info("%s: setting arp_validate to %s (%d).\n",
+		bond->dev->name, arp_validate_tbl[new_value].modename,
+		new_value);
 
 	if (!bond->params.arp_validate && new_value)
 		bond_register_arp(bond);
@@ -517,24 +505,22 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->slave_cnt != 0) {
-		pr_err(DRV_NAME
-		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
+		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
 		return -EPERM;
 	}
 
 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid fail_over_mac value %s.\n",
+		pr_err("%s: Ignoring invalid fail_over_mac value %s.\n",
 		       bond->dev->name, buf);
 		return -EINVAL;
 	}
 
 	bond->params.fail_over_mac = new_value;
-	pr_info(DRV_NAME ": %s: Setting fail_over_mac to %s (%d).\n",
-	       bond->dev->name, fail_over_mac_tbl[new_value].modename,
-	       new_value);
+	pr_info("%s: Setting fail_over_mac to %s (%d).\n",
+		bond->dev->name, fail_over_mac_tbl[new_value].modename,
+		new_value);
 
 	return count;
 }
@@ -565,31 +551,26 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no arp_interval value specified.\n",
+		pr_err("%s: no arp_interval value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid arp_interval value %d not in range 1-%d; rejected.\n",
+		pr_err("%s: Invalid arp_interval value %d not in range 1-%d; rejected.\n",
 		       bond->dev->name, new_value, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	}
 
-	pr_info(DRV_NAME
-	       ": %s: Setting ARP monitoring interval to %d.\n",
-	       bond->dev->name, new_value);
+	pr_info("%s: Setting ARP monitoring interval to %d.\n",
+		bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
 	if (bond->params.arp_interval)
 		bond->dev->priv_flags |= IFF_MASTER_ARPMON;
 	if (bond->params.miimon) {
-		pr_info(DRV_NAME
-		       ": %s: ARP monitoring cannot be used with MII monitoring. "
-		       "%s Disabling MII monitoring.\n",
-		       bond->dev->name, bond->dev->name);
+		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
+			bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
 		if (delayed_work_pending(&bond->mii_work)) {
 			cancel_delayed_work(&bond->mii_work);
@@ -597,10 +578,8 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		}
 	}
 	if (!bond->params.arp_targets[0]) {
-		pr_info(DRV_NAME
-		       ": %s: ARP monitoring has been set up, "
-		       "but no ARP targets have been specified.\n",
-		       bond->dev->name);
+		pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
+			bond->dev->name);
 	}
 	if (bond->dev->flags & IFF_UP) {
 		/* If the interface is up, we may need to fire off
@@ -660,8 +639,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 	/* look for adds */
 	if (buf[0] == '+') {
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err(DRV_NAME
-			       ": %s: invalid ARP target %pI4 specified for addition\n",
+			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
@@ -669,23 +647,20 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		/* look for an empty slot to put the target in, and check for dupes */
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) { /* duplicate */
-				pr_err(DRV_NAME
-				       ": %s: ARP target %pI4 is already present\n",
+				pr_err("%s: ARP target %pI4 is already present\n",
 				       bond->dev->name, &newtarget);
 				ret = -EINVAL;
 				goto out;
 			}
 			if (targets[i] == 0) {
-				pr_info(DRV_NAME
-				       ": %s: adding ARP target %pI4.\n",
-				       bond->dev->name, &newtarget);
+				pr_info("%s: adding ARP target %pI4.\n",
+					bond->dev->name, &newtarget);
 				done = 1;
 				targets[i] = newtarget;
 			}
 		}
 		if (!done) {
-			pr_err(DRV_NAME
-			       ": %s: ARP target table is full!\n",
+			pr_err("%s: ARP target table is full!\n",
 			       bond->dev->name);
 			ret = -EINVAL;
 			goto out;
@@ -693,8 +668,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 
 	} else if (buf[0] == '-')	{
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err(DRV_NAME
-			       ": %s: invalid ARP target %pI4 specified for removal\n",
+			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
@@ -703,9 +677,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) {
 				int j;
-				pr_info(DRV_NAME
-				       ": %s: removing ARP target %pI4.\n",
-				       bond->dev->name, &newtarget);
+				pr_info("%s: removing ARP target %pI4.\n",
+					bond->dev->name, &newtarget);
 				for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j+1]; j++)
 					targets[j] = targets[j+1];
 
@@ -714,16 +687,14 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			}
 		}
 		if (!done) {
-			pr_info(DRV_NAME
-			       ": %s: unable to remove nonexistent ARP target %pI4.\n",
-			       bond->dev->name, &newtarget);
+			pr_info("%s: unable to remove nonexistent ARP target %pI4.\n",
+				bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
 		}
 	} else {
-		pr_err(DRV_NAME ": no command found in arp_ip_targets file"
-		       " for bond %s. Use +<addr> or -<addr>.\n",
-			bond->dev->name);
+		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
+		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
@@ -755,41 +726,34 @@ static ssize_t bonding_store_downdelay(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (!(bond->params.miimon)) {
-		pr_err(DRV_NAME
-		       ": %s: Unable to set down delay as MII monitoring is disabled\n",
+		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no down delay value specified.\n",
-		       bond->dev->name);
+		pr_err("%s: no down delay value specified.\n", bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid down delay value %d not in range %d-%d; rejected.\n",
+		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
 		if ((new_value % bond->params.miimon) != 0) {
-			pr_warning(DRV_NAME
-				   ": %s: Warning: down delay (%d) is not a "
-				   "multiple of miimon (%d), delay rounded "
-				   "to %d ms\n",
+			pr_warning("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
 				   bond->dev->name, new_value,
 				   bond->params.miimon,
 				   (new_value / bond->params.miimon) *
 				   bond->params.miimon);
 		}
 		bond->params.downdelay = new_value / bond->params.miimon;
-		pr_info(DRV_NAME ": %s: Setting down delay to %d.\n",
-		       bond->dev->name,
-		       bond->params.downdelay * bond->params.miimon);
+		pr_info("%s: Setting down delay to %d.\n",
+			bond->dev->name,
+			bond->params.downdelay * bond->params.miimon);
 
 	}
 
@@ -817,41 +781,35 @@ static ssize_t bonding_store_updelay(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (!(bond->params.miimon)) {
-		pr_err(DRV_NAME
-		       ": %s: Unable to set up delay as MII monitoring is disabled\n",
+		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no up delay value specified.\n",
+		pr_err("%s: no up delay value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid down delay value %d not in range %d-%d; rejected.\n",
+		pr_err("%s: Invalid down delay value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
 		if ((new_value % bond->params.miimon) != 0) {
-			pr_warning(DRV_NAME
-				   ": %s: Warning: up delay (%d) is not a "
-				   "multiple of miimon (%d), updelay rounded "
-				   "to %d ms\n",
+			pr_warning("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
 				   bond->dev->name, new_value,
 				   bond->params.miimon,
 				   (new_value / bond->params.miimon) *
 				   bond->params.miimon);
 		}
 		bond->params.updelay = new_value / bond->params.miimon;
-		pr_info(DRV_NAME ": %s: Setting up delay to %d.\n",
-		       bond->dev->name, bond->params.updelay * bond->params.miimon);
-
+		pr_info("%s: Setting up delay to %d.\n",
+			bond->dev->name,
+			bond->params.updelay * bond->params.miimon);
 	}
 
 out:
@@ -883,16 +841,14 @@ static ssize_t bonding_store_lacp(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		pr_err(DRV_NAME
-		       ": %s: Unable to update LACP rate because interface is up.\n",
+		pr_err("%s: Unable to update LACP rate because interface is up.\n",
 		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
 
 	if (bond->params.mode != BOND_MODE_8023AD) {
-		pr_err(DRV_NAME
-		       ": %s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
+		pr_err("%s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
 		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
@@ -902,12 +858,11 @@ static ssize_t bonding_store_lacp(struct device *d,
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
-		pr_info(DRV_NAME ": %s: Setting LACP rate to %s (%d).\n",
+		pr_info("%s: Setting LACP rate to %s (%d).\n",
 			bond->dev->name, bond_lacp_tbl[new_value].modename,
 			new_value);
 	} else {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid LACP rate value %.*s.\n",
+		pr_err("%s: Ignoring invalid LACP rate value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
 	}
@@ -937,9 +892,8 @@ static ssize_t bonding_store_ad_select(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		pr_err(DRV_NAME
-		       ": %s: Unable to update ad_select because interface "
-		       "is up.\n", bond->dev->name);
+		pr_err("%s: Unable to update ad_select because interface is up.\n",
+		       bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
@@ -948,13 +902,11 @@ static ssize_t bonding_store_ad_select(struct device *d,
 
 	if (new_value != -1) {
 		bond->params.ad_select = new_value;
-		pr_info(DRV_NAME
-		       ": %s: Setting ad_select to %s (%d).\n",
-		       bond->dev->name, ad_select_tbl[new_value].modename,
-		       new_value);
+		pr_info("%s: Setting ad_select to %s (%d).\n",
+			bond->dev->name, ad_select_tbl[new_value].modename,
+			new_value);
 	} else {
-		pr_err(DRV_NAME
-		       ": %s: Ignoring invalid ad_select value %.*s.\n",
+		pr_err("%s: Ignoring invalid ad_select value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
 	}
@@ -984,15 +936,13 @@ static ssize_t bonding_store_n_grat_arp(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no num_grat_arp value specified.\n",
+		pr_err("%s: no num_grat_arp value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0 || new_value > 255) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
+		pr_err("%s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
 		       bond->dev->name, new_value);
 		ret = -EINVAL;
 		goto out;
@@ -1025,16 +975,14 @@ static ssize_t bonding_store_n_unsol_na(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no num_unsol_na value specified.\n",
+		pr_err("%s: no num_unsol_na value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 
 	if (new_value < 0 || new_value > 255) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
+		pr_err("%s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
 		       bond->dev->name, new_value);
 		ret = -EINVAL;
 		goto out;
@@ -1069,40 +1017,31 @@ static ssize_t bonding_store_miimon(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no miimon value specified.\n",
+		pr_err("%s: no miimon value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		pr_err(DRV_NAME
-		       ": %s: Invalid miimon value %d not in range %d-%d; rejected.\n",
+		pr_err("%s: Invalid miimon value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
-		pr_info(DRV_NAME
-		       ": %s: Setting MII monitoring interval to %d.\n",
-		       bond->dev->name, new_value);
+		pr_info("%s: Setting MII monitoring interval to %d.\n",
+			bond->dev->name, new_value);
 		bond->params.miimon = new_value;
 		if (bond->params.updelay)
-			pr_info(DRV_NAME
-			      ": %s: Note: Updating updelay (to %d) "
-			      "since it is a multiple of the miimon value.\n",
-			      bond->dev->name,
-			      bond->params.updelay * bond->params.miimon);
+			pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
+				bond->dev->name,
+				bond->params.updelay * bond->params.miimon);
 		if (bond->params.downdelay)
-			pr_info(DRV_NAME
-			      ": %s: Note: Updating downdelay (to %d) "
-			      "since it is a multiple of the miimon value.\n",
-			      bond->dev->name,
-			      bond->params.downdelay * bond->params.miimon);
+			pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
+				bond->dev->name,
+				bond->params.downdelay * bond->params.miimon);
 		if (bond->params.arp_interval) {
-			pr_info(DRV_NAME
-			       ": %s: MII monitoring cannot be used with "
-			       "ARP monitoring. Disabling ARP monitoring...\n",
-			       bond->dev->name);
+			pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
+				bond->dev->name);
 			bond->params.arp_interval = 0;
 			bond->dev->priv_flags &= ~IFF_MASTER_ARPMON;
 			if (bond->params.arp_validate) {
@@ -1170,17 +1109,15 @@ static ssize_t bonding_store_primary(struct device *d,
 	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
-		pr_info(DRV_NAME
-		       ": %s: Unable to set primary slave; %s is in mode %d\n",
-		       bond->dev->name, bond->dev->name, bond->params.mode);
+		pr_info("%s: Unable to set primary slave; %s is in mode %d\n",
+			bond->dev->name, bond->dev->name, bond->params.mode);
 	} else {
 		bond_for_each_slave(bond, slave, i) {
 			if (strnicmp
 			    (slave->dev->name, buf,
 			     strlen(slave->dev->name)) == 0) {
-				pr_info(DRV_NAME
-				       ": %s: Setting %s as primary slave.\n",
-				       bond->dev->name, slave->dev->name);
+				pr_info("%s: Setting %s as primary slave.\n",
+					bond->dev->name, slave->dev->name);
 				bond->primary_slave = slave;
 				strcpy(bond->params.primary, slave->dev->name);
 				bond_select_active_slave(bond);
@@ -1191,15 +1128,13 @@ static ssize_t bonding_store_primary(struct device *d,
 		/* if we got here, then we didn't match the name of any slave */
 
 		if (strlen(buf) == 0 || buf[0] == '\n') {
-			pr_info(DRV_NAME
-			       ": %s: Setting primary slave to None.\n",
-			       bond->dev->name);
+			pr_info("%s: Setting primary slave to None.\n",
+				bond->dev->name);
 			bond->primary_slave = NULL;
 				bond_select_active_slave(bond);
 		} else {
-			pr_info(DRV_NAME
-			       ": %s: Unable to set %.*s as primary slave as it is not a slave.\n",
-			       bond->dev->name, (int)strlen(buf) - 1, buf);
+			pr_info("%s: Unable to set %.*s as primary slave as it is not a slave.\n",
+				bond->dev->name, (int)strlen(buf) - 1, buf);
 		}
 	}
 out:
@@ -1233,20 +1168,18 @@ static ssize_t bonding_store_carrier(struct device *d,
 
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err(DRV_NAME
-		       ": %s: no use_carrier value specified.\n",
+		pr_err("%s: no use_carrier value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if ((new_value == 0) || (new_value == 1)) {
 		bond->params.use_carrier = new_value;
-		pr_info(DRV_NAME ": %s: Setting use_carrier to %d.\n",
-		       bond->dev->name, new_value);
+		pr_info("%s: Setting use_carrier to %d.\n",
+			bond->dev->name, new_value);
 	} else {
-		pr_info(DRV_NAME
-		       ": %s: Ignoring invalid use_carrier value %d.\n",
-		       bond->dev->name, new_value);
+		pr_info("%s: Ignoring invalid use_carrier value %d.\n",
+			bond->dev->name, new_value);
 	}
 out:
 	return count;
@@ -1291,8 +1224,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode))
-		pr_info(DRV_NAME ": %s: Unable to change active slave;"
-			" %s is in mode %d\n",
+		pr_info("%s: Unable to change active slave; %s is in mode %d\n",
 			bond->dev->name, bond->dev->name, bond->params.mode);
 	else {
 		bond_for_each_slave(bond, slave, i) {
@@ -1303,9 +1235,9 @@ static ssize_t bonding_store_active_slave(struct device *d,
         			new_active = slave;
         			if (new_active == old_active) {
 					/* do nothing */
-					pr_info(DRV_NAME
-						": %s: %s is already the current active slave.\n",
-						bond->dev->name, slave->dev->name);
+					pr_info("%s: %s is already the current active slave.\n",
+						bond->dev->name,
+						slave->dev->name);
 					goto out;
 				}
 				else {
@@ -1313,16 +1245,15 @@ static ssize_t bonding_store_active_slave(struct device *d,
             				    (old_active) &&
 				            (new_active->link == BOND_LINK_UP) &&
 				            IS_UP(new_active->dev)) {
-						pr_info(DRV_NAME
-							": %s: Setting %s as active slave.\n",
-							bond->dev->name, slave->dev->name);
+						pr_info("%s: Setting %s as active slave.\n",
+							bond->dev->name,
+							slave->dev->name);
 							bond_change_active_slave(bond, new_active);
         				}
 					else {
-						pr_info(DRV_NAME
-							": %s: Could not set %s as active slave; "
-							"either %s is down or the link is down.\n",
-							bond->dev->name, slave->dev->name,
+						pr_info("%s: Could not set %s as active slave; either %s is down or the link is down.\n",
+							bond->dev->name,
+							slave->dev->name,
 							slave->dev->name);
 					}
 					goto out;
@@ -1333,14 +1264,12 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		/* if we got here, then we didn't match the name of any slave */
 
 		if (strlen(buf) == 0 || buf[0] == '\n') {
-			pr_info(DRV_NAME
-				": %s: Setting active slave to None.\n",
+			pr_info("%s: Setting active slave to None.\n",
 				bond->dev->name);
 			bond->primary_slave = NULL;
 			bond_select_active_slave(bond);
 		} else {
-			pr_info(DRV_NAME ": %s: Unable to set %.*s"
-				" as active slave as it is not a slave.\n",
+			pr_info("%s: Unable to set %.*s as active slave as it is not a slave.\n",
 				bond->dev->name, (int)strlen(buf) - 1, buf);
 		}
 	}
@@ -1541,8 +1470,7 @@ int bond_create_sysfs(void)
 		/* Is someone being kinky and naming a device bonding_master? */
 		if (__dev_get_by_name(&init_net,
 				      class_attr_bonding_masters.attr.name))
-			pr_err("network device named %s already "
-			       "exists in sysfs",
+			pr_err("network device named %s already exists in sysfs",
 			       class_attr_bonding_masters.attr.name);
 		ret = 0;
 	}
-- 
1.6.3.1.10.g659a0.dirty

