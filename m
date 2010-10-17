From: Bandan Das <bandan.das@stratus.com>
Subject: [PATCH 2/2] bonding: cleanup: remove braces from single block statements
Date: Sun, 17 Oct 2010 02:19:59 -0400
Message-ID: <1287296399-25142-3-git-send-email-bandan.das@stratus.com>
References: <1287296399-25142-1-git-send-email-bandan.das@stratus.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, joe@perches.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bandan Das <bandan.das@stratus.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287296399-25142-1-git-send-email-bandan.das@stratus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

checkpatch.pl cleanup : Remove braces from single statement
blocks.

Signed-off-by: Bandan Das <bandan.das@stratus.com>
---
 drivers/net/bonding/bond_3ad.c |  163 ++++++++++++++++++----------------------
 1 files changed, 72 insertions(+), 91 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6b06b00..881914b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -129,9 +129,8 @@ static void ad_marker_response_received(struct bond_marker *marker, struct port
  */
 static inline struct bonding *__get_bond_by_port(struct port *port)
 {
-	if (port->slave == NULL) {
+	if (port->slave == NULL)
 		return NULL;
-	}
 
 	return bond_get_bond_by_slave(port->slave);
 }
@@ -144,9 +143,8 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
  */
 static inline struct port *__get_first_port(struct bonding *bond)
 {
-	if (bond->slave_cnt == 0) {
+	if (bond->slave_cnt == 0)
 		return NULL;
-	}
 
 	return &(SLAVE_AD_INFO(bond->first_slave).port);
 }
@@ -164,9 +162,8 @@ static inline struct port *__get_next_port(struct port *port)
 	struct slave *slave = port->slave;
 
 	// If there's no bond for this port, or this is the last slave
-	if ((bond == NULL) || (slave->next == bond->first_slave)) {
+	if ((bond == NULL) || (slave->next == bond->first_slave))
 		return NULL;
-	}
 
 	return &(SLAVE_AD_INFO(slave->next).port);
 }
@@ -183,9 +180,8 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 	struct bonding *bond = __get_bond_by_port(port);
 
 	// If there's no bond for this port, or bond has no slaves
-	if ((bond == NULL) || (bond->slave_cnt == 0)) {
+	if ((bond == NULL) || (bond->slave_cnt == 0))
 		return NULL;
-	}
 
 	return &(SLAVE_AD_INFO(bond->first_slave).aggregator);
 }
@@ -203,9 +199,8 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 
 	// If there's no bond for this aggregator, or this is the last slave
-	if ((bond == NULL) || (slave->next == bond->first_slave)) {
+	if ((bond == NULL) || (slave->next == bond->first_slave))
 		return NULL;
-	}
 
 	return &(SLAVE_AD_INFO(slave->next).aggregator);
 }
@@ -240,9 +235,8 @@ static inline void __enable_port(struct port *port)
 {
 	struct slave *slave = port->slave;
 
-	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev)) {
+	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev))
 		bond_set_slave_active_flags(slave);
-	}
 }
 
 /**
@@ -265,9 +259,8 @@ static inline u32 __get_agg_selection_mode(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 
-	if (bond == NULL) {
+	if (bond == NULL)
 		return BOND_AD_STABLE;
-	}
 
 	return BOND_AD_INFO(bond).agg_select_mode;
 }
@@ -281,9 +274,8 @@ static inline int __check_agg_selection_timer(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 
-	if (bond == NULL) {
+	if (bond == NULL)
 		return 0;
-	}
 
 	return BOND_AD_INFO(bond).agg_select_timer ? 1 : 0;
 }
@@ -328,9 +320,9 @@ static u16 __get_link_speed(struct port *port)
 	 * link down, it sets the speed to 0.
 	 * This is done in spite of the fact that the e100 driver reports 0 to be
 	 * compatible with MVT in the future.*/
-	if (slave->link != BOND_LINK_UP) {
+	if (slave->link != BOND_LINK_UP)
 		speed = 0;
-	} else {
+	else {
 		switch (slave->speed) {
 		case SPEED_10:
 			speed = AD_LINK_SPEED_BITMASK_10MBPS;
@@ -375,9 +367,9 @@ static u8 __get_duplex(struct port *port)
 
 	//  handling a special case: when the configuration starts with
 	// link down, it sets the duplex to 0.
-	if (slave->link != BOND_LINK_UP) {
+	if (slave->link != BOND_LINK_UP)
 		retval = 0x0;
-	} else {
+	else {
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval = 0x1;
@@ -423,11 +415,10 @@ static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
 
 	switch (timer_type) {
 	case AD_CURRENT_WHILE_TIMER:   // for rx machine usage
-		if (par) {	      // for short or long timeout
+		if (par)
 			retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec); // short timeout
-		} else {
+		else
 			retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec); // long timeout
-		}
 		break;
 	case AD_ACTOR_CHURN_TIMER:	    // for local churn machine
 		retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
@@ -519,11 +510,11 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;
 
 		// set the partner sync. to on if the partner is sync. and the port is matched
-		if ((port->sm_vars & AD_PORT_MATCHED) && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
+		if ((port->sm_vars & AD_PORT_MATCHED)
+		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
 			partner->port_state |= AD_STATE_SYNCHRONIZATION;
-		} else {
+		else
 			partner->port_state &= ~AD_STATE_SYNCHRONIZATION;
-		}
 	}
 }
 
@@ -710,11 +701,10 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
 
 	for (port = aggregator->lag_ports; port;
 	     port = port->next_port_in_aggregator) {
-		if (val) {
+		if (val)
 			port->sm_vars |= AD_PORT_READY;
-		} else {
+		else
 			port->sm_vars &= ~AD_PORT_READY;
-		}
 	}
 }
 
@@ -838,9 +828,8 @@ static int ad_lacpdu_send(struct port *port)
 	int length = sizeof(struct lacpdu_header);
 
 	skb = dev_alloc_skb(length);
-	if (!skb) {
+	if (!skb)
 		return -ENOMEM;
-	}
 
 	skb->dev = slave->dev;
 	skb_reset_mac_header(skb);
@@ -879,9 +868,8 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 	int length = sizeof(struct bond_marker_header);
 
 	skb = dev_alloc_skb(length + 16);
-	if (!skb) {
+	if (!skb)
 		return -ENOMEM;
-	}
 
 	skb_reserve(skb, 16);
 
@@ -922,9 +910,10 @@ static void ad_mux_machine(struct port *port)
 	} else {
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
-			if ((port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY)) { // if SELECTED or STANDBY
+			if ((port->sm_vars & AD_PORT_SELECTED)
+			    || (port->sm_vars & AD_PORT_STANDBY))
+				/* if SELECTED or STANDBY */
 				port->sm_mux_state = AD_MUX_WAITING; // next state
-			}
 			break;
 		case AD_MUX_WAITING:
 			// if SELECTED == FALSE return to DETACH state
@@ -938,18 +927,18 @@ static void ad_mux_machine(struct port *port)
 			}
 
 			// check if the wait_while_timer expired
-			if (port->sm_mux_timer_counter && !(--port->sm_mux_timer_counter)) {
+			if (port->sm_mux_timer_counter
+			    && !(--port->sm_mux_timer_counter))
 				port->sm_vars |= AD_PORT_READY_N;
-			}
 
 			// in order to withhold the selection logic to check all ports READY_N value
 			// every callback cycle to update ready variable, we check READY_N and update READY here
 			__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 
 			// if the wait_while_timer expired, and the port is in READY state, move to ATTACHED state
-			if ((port->sm_vars & AD_PORT_READY) && !port->sm_mux_timer_counter) {
+			if ((port->sm_vars & AD_PORT_READY)
+			    && !port->sm_mux_timer_counter)
 				port->sm_mux_state = AD_MUX_ATTACHED;	 // next state
-			}
 			break;
 		case AD_MUX_ATTACHED:
 			// check also if agg_select_timer expired(so the edable port will take place only after this timer)
@@ -1044,13 +1033,14 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 
 	// check if state machine should change state
 	// first, check if port was reinitialized
-	if (port->sm_vars & AD_PORT_BEGIN) {
-		port->sm_rx_state = AD_RX_INITIALIZE;		    // next state
-	}
+	if (port->sm_vars & AD_PORT_BEGIN)
+		/* next state */
+		port->sm_rx_state = AD_RX_INITIALIZE;
 	// check if port is not enabled
-	else if (!(port->sm_vars & AD_PORT_BEGIN) && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED)) {
-		port->sm_rx_state = AD_RX_PORT_DISABLED;	    // next state
-	}
+	else if (!(port->sm_vars & AD_PORT_BEGIN)
+		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
+		/* next state */
+		port->sm_rx_state = AD_RX_PORT_DISABLED;
 	// check if new lacpdu arrived
 	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) || (port->sm_rx_state == AD_RX_DEFAULTED) || (port->sm_rx_state == AD_RX_CURRENT))) {
 		port->sm_rx_timer_counter = 0; // zero timer
@@ -1072,13 +1062,16 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			// if no lacpdu arrived and no timer is on
 			switch (port->sm_rx_state) {
 			case AD_RX_PORT_DISABLED:
-				if (port->sm_vars & AD_PORT_MOVED) {
+				if (port->sm_vars & AD_PORT_MOVED)
 					port->sm_rx_state = AD_RX_INITIALIZE;	    // next state
-				} else if (port->is_enabled && (port->sm_vars & AD_PORT_LACP_ENABLED)) {
+				else if (port->is_enabled
+					 && (port->sm_vars
+					     & AD_PORT_LACP_ENABLED))
 					port->sm_rx_state = AD_RX_EXPIRED;	// next state
-				} else if (port->is_enabled && ((port->sm_vars & AD_PORT_LACP_ENABLED) == 0)) {
+				else if (port->is_enabled
+					 && ((port->sm_vars
+					      & AD_PORT_LACP_ENABLED) == 0))
 					port->sm_rx_state = AD_RX_LACP_DISABLED;    // next state
-				}
 				break;
 			default:    //to silence the compiler
 				break;
@@ -1094,11 +1087,10 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			 port->sm_rx_state);
 		switch (port->sm_rx_state) {
 		case AD_RX_INITIALIZE:
-			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
+			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
 				port->sm_vars &= ~AD_PORT_LACP_ENABLED;
-			} else {
+			else
 				port->sm_vars |= AD_PORT_LACP_ENABLED;
-			}
 			port->sm_vars &= ~AD_PORT_SELECTED;
 			__record_default(port);
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
@@ -1152,9 +1144,10 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			// verify that if the aggregator is enabled, the port is enabled too.
 			//(because if the link goes down for a short time, the 802.3ad will not
 			// catch it, and the port will continue to be disabled)
-			if (port->aggregator && port->aggregator->is_active && !__port_is_enabled(port)) {
+			if (port->aggregator
+			    && port->aggregator->is_active
+			    && !__port_is_enabled(port))
 				__enable_port(port);
-			}
 			break;
 		default:    //to silence the compiler
 			break;
@@ -1220,9 +1213,9 @@ static void ad_periodic_machine(struct port *port)
 			// If not expired, check if there is some new timeout parameter from the partner state
 			switch (port->sm_periodic_state) {
 			case AD_FAST_PERIODIC:
-				if (!(port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
+				if (!(port->partner_oper.port_state
+				      & AD_STATE_LACP_TIMEOUT))
 					port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
-				}
 				break;
 			case AD_SLOW_PERIODIC:
 				if ((port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
@@ -1241,11 +1234,11 @@ static void ad_periodic_machine(struct port *port)
 			port->sm_periodic_state = AD_FAST_PERIODIC;	 // next state
 			break;
 		case AD_PERIODIC_TX:
-			if (!(port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
+			if (!(port->partner_oper.port_state
+			      & AD_STATE_LACP_TIMEOUT))
 				port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
-			} else {
+			else
 				port->sm_periodic_state = AD_FAST_PERIODIC;  // next state
-			}
 			break;
 		default:    //to silence the compiler
 			break;
@@ -1291,9 +1284,8 @@ static void ad_port_selection_logic(struct port *port)
 	int found = 0;
 
 	// if the port is already Selected, do nothing
-	if (port->sm_vars & AD_PORT_SELECTED) {
+	if (port->sm_vars & AD_PORT_SELECTED)
 		return;
-	}
 
 	// if the port is connected to other aggregator, detach it
 	if (port->aggregator) {
@@ -1321,9 +1313,8 @@ static void ad_port_selection_logic(struct port *port)
 					 port->actor_port_number,
 					 temp_aggregator->aggregator_identifier);
 				// if the aggregator is empty, clear its parameters, and set it ready to be attached
-				if (!temp_aggregator->lag_ports) {
+				if (!temp_aggregator->lag_ports)
 					ad_clear_agg(temp_aggregator);
-				}
 				break;
 			}
 		}
@@ -1341,9 +1332,8 @@ static void ad_port_selection_logic(struct port *port)
 
 		// keep a free aggregator for later use(if needed)
 		if (!aggregator->lag_ports) {
-			if (!free_aggregator) {
+			if (!free_aggregator)
 				free_aggregator = aggregator;
-			}
 			continue;
 		}
 		// check if current aggregator suits us
@@ -1384,11 +1374,11 @@ static void ad_port_selection_logic(struct port *port)
 
 			// update the new aggregator's parameters
 			// if port was responsed from the end-user
-			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS) {// if port is full duplex
+			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)
+				/* if port is full duplex */
 				port->aggregator->is_individual = false;
-			} else {
+			else
 				port->aggregator->is_individual = true;
-			}
 
 			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
 			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
@@ -1716,9 +1706,8 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		port->actor_admin_port_state = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
 		port->actor_oper_port_state  = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
 
-		if (lacp_fast) {
+		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
-		}
 
 		memcpy(&port->partner_admin, &tmpl, sizeof(tmpl));
 		memcpy(&port->partner_oper, &tmpl, sizeof(tmpl));
@@ -1947,9 +1936,8 @@ int bond_3ad_bind_slave(struct slave *slave)
 		port->actor_admin_port_key |= (__get_link_speed(port) << 1);
 		port->actor_oper_port_key = port->actor_admin_port_key;
 		// if the port is not full duplex, then the port should be not lacp Enabled
-		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)) {
+		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
-		}
 		// actor system is the bond's system
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
 		// tx timer(to verify that no more than MAX_TX_IN_SECOND lacpdu's are sent in one second)
@@ -2021,9 +2009,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			new_aggregator = __get_first_agg(port);
 			for (; new_aggregator; new_aggregator = __get_next_agg(new_aggregator)) {
 				// if the new aggregator is empty, or it is connected to our port only
-				if (!new_aggregator->lag_ports || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator)) {
+				if (!new_aggregator->lag_ports
+				    || ((new_aggregator->lag_ports == port)
+					&& !new_aggregator->lag_ports->next_port_in_aggregator))
 					break;
-				}
 			}
 			// if new aggregator found, copy the aggregator's parameters
 			// and connect the related lag_ports to the new aggregator
@@ -2061,9 +2050,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				// clear the aggregator
 				ad_clear_agg(aggregator);
 
-				if (select_new_active_agg) {
+				if (select_new_active_agg)
 					ad_agg_selection_logic(__get_first_agg(port));
-				}
 			} else {
 				pr_warning("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
 					   slave->dev->master->name);
@@ -2091,11 +2079,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
 		     prev_port = temp_port,
 			     temp_port = temp_port->next_port_in_aggregator) {
 			if (temp_port == port) { // the aggregator found - detach the port from this aggregator
-				if (prev_port) {
+				if (prev_port)
 					prev_port->next_port_in_aggregator = temp_port->next_port_in_aggregator;
-				} else {
+				else
 					temp_aggregator->lag_ports = temp_port->next_port_in_aggregator;
-				}
 				temp_aggregator->num_of_ports--;
 				if (temp_aggregator->num_of_ports == 0) {
 					select_new_active_agg = temp_aggregator->is_active;
@@ -2137,14 +2124,12 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers) {
+	if (bond->kill_timers)
 		goto out;
-	}
 
 	//check if there are any slaves
-	if (bond->slave_cnt == 0) {
+	if (bond->slave_cnt == 0)
 		goto re_arm;
-	}
 
 	// check if agg_select_timer timer after initialize is timed out
 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
@@ -2177,9 +2162,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		ad_tx_machine(port);
 
 		// turn off the BEGIN bit, since we already handled it
-		if (port->sm_vars & AD_PORT_BEGIN) {
+		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
-		}
 	}
 
 re_arm:
@@ -2417,9 +2401,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	 */
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond)) {
+	if (!BOND_IS_OK(bond))
 		goto out;
-	}
 
 	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: bond_3ad_get_active_agg_info failed\n",
@@ -2443,9 +2426,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 		if (agg && (agg->aggregator_identifier == agg_id)) {
 			slave_agg_no--;
-			if (slave_agg_no < 0) {
+			if (slave_agg_no < 0)
 				break;
-			}
 		}
 	}
 
@@ -2461,9 +2443,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		int slave_agg_id = 0;
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
-		if (agg) {
+		if (agg)
 			slave_agg_id = agg->aggregator_identifier;
-		}
 
 		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-- 
1.7.2.3
