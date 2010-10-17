From: Bandan Das <bandan.das@stratus.com>
Subject: [PATCH 1/2] bonding: cleanup : add space around operators
Date: Sun, 17 Oct 2010 02:19:58 -0400
Message-ID: <1287296399-25142-2-git-send-email-bandan.das@stratus.com>
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

checkpatch.pl cleanup: Added spaces around operators at various places.
Also fixed some c99 style comments that I came across.

Signed-off-by: Bandan Das <bandan.das@stratus.com>
---
 drivers/net/bonding/bond_3ad.c |  111 ++++++++++++++++++++++++----------------
 1 files changed, 67 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 079b9d1..6b06b00 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -93,7 +93,7 @@
 // compare MAC addresses
 #define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
 
-static struct mac_addr null_mac_addr = {{0, 0, 0, 0, 0, 0}};
+static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
 static u16 ad_ticks_per_sec;
 static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
@@ -329,7 +329,7 @@ static u16 __get_link_speed(struct port *port)
 	 * This is done in spite of the fact that the e100 driver reports 0 to be
 	 * compatible with MVT in the future.*/
 	if (slave->link != BOND_LINK_UP) {
-		speed=0;
+		speed = 0;
 	} else {
 		switch (slave->speed) {
 		case SPEED_10:
@@ -376,17 +376,17 @@ static u8 __get_duplex(struct port *port)
 	//  handling a special case: when the configuration starts with
 	// link down, it sets the duplex to 0.
 	if (slave->link != BOND_LINK_UP) {
-		retval=0x0;
+		retval = 0x0;
 	} else {
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
-			retval=0x1;
+			retval = 0x1;
 			pr_debug("Port %d Received status full duplex update from adapter\n",
 				 port->actor_port_number);
 			break;
 		case DUPLEX_HALF:
 		default:
-			retval=0x0;
+			retval = 0x0;
 			pr_debug("Port %d Received status NOT full duplex update from adapter\n",
 				 port->actor_port_number);
 			break;
@@ -419,7 +419,7 @@ static inline void __initialize_port_locks(struct port *port)
  */
 static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
 {
-	u16 retval=0;	 //to silence the compiler
+	u16 retval = 0; /* to silence the compiler */
 
 	switch (timer_type) {
 	case AD_CURRENT_WHILE_TIMER:   // for rx machine usage
@@ -653,7 +653,7 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
  */
 static void __attach_bond_to_agg(struct port *port)
 {
-	port=NULL; // just to satisfy the compiler
+	port = NULL; /* just to satisfy the compiler */
 	// This function does nothing since the parser/multiplexer of the receive
 	// and the parser/multiplexer of the aggregator are already combined
 }
@@ -668,7 +668,7 @@ static void __attach_bond_to_agg(struct port *port)
  */
 static void __detach_bond_from_agg(struct port *port)
 {
-	port=NULL; // just to satisfy the compiler
+	port = NULL; /* just to satisfy the compiler */
 	// This function does nothing sience the parser/multiplexer of the receive
 	// and the parser/multiplexer of the aggregator are already combined
 }
@@ -685,7 +685,9 @@ static int __agg_ports_are_ready(struct aggregator *aggregator)
 
 	if (aggregator) {
 		// scan all ports in this aggregator to verfy if they are all ready
-		for (port=aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+		for (port = aggregator->lag_ports;
+		     port;
+		     port = port->next_port_in_aggregator) {
 			if (!(port->sm_vars & AD_PORT_READY_N)) {
 				retval = 0;
 				break;
@@ -706,7 +708,8 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
 {
 	struct port *port;
 
-	for (port=aggregator->lag_ports; port; port=port->next_port_in_aggregator) {
+	for (port = aggregator->lag_ports; port;
+	     port = port->next_port_in_aggregator) {
 		if (val) {
 			port->sm_vars |= AD_PORT_READY;
 		} else {
@@ -722,7 +725,7 @@ static void __set_agg_ports_ready(struct aggregator *aggregator, int val)
  */
 static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 {
-	u32 bandwidth=0;
+	u32 bandwidth = 0;
 	u32 basic_speed;
 
 	if (aggregator->num_of_ports) {
@@ -744,7 +747,7 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
 		default:
-			bandwidth=0; // to silent the compilor ....
+			bandwidth = 0; /*to silence the compiler ....*/
 		}
 	}
 	return bandwidth;
@@ -1183,7 +1186,8 @@ static void ad_tx_machine(struct port *port)
 			}
 		}
 		// restart tx timer(to verify that we will not exceed AD_MAX_TX_IN_SECOND
-		port->sm_tx_timer_counter=ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
+		port->sm_tx_timer_counter =
+			ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 	}
 }
 
@@ -1294,20 +1298,24 @@ static void ad_port_selection_logic(struct port *port)
 	// if the port is connected to other aggregator, detach it
 	if (port->aggregator) {
 		// detach the port from its former aggregator
-		temp_aggregator=port->aggregator;
-		for (curr_port=temp_aggregator->lag_ports; curr_port; last_port=curr_port, curr_port=curr_port->next_port_in_aggregator) {
+		temp_aggregator = port->aggregator;
+		for (curr_port = temp_aggregator->lag_ports; curr_port;
+		     last_port = curr_port,
+			     curr_port = curr_port->next_port_in_aggregator) {
 			if (curr_port == port) {
 				temp_aggregator->num_of_ports--;
 				if (!last_port) {// if it is the first port attached to the aggregator
-					temp_aggregator->lag_ports=port->next_port_in_aggregator;
+					temp_aggregator->lag_ports =
+						port->next_port_in_aggregator;
 				} else {// not the first port attached to the aggregator
-					last_port->next_port_in_aggregator=port->next_port_in_aggregator;
+					last_port->next_port_in_aggregator =
+						port->next_port_in_aggregator;
 				}
 
 				// clear the port's relations to this aggregator
 				port->aggregator = NULL;
-				port->next_port_in_aggregator=NULL;
-				port->actor_port_aggregator_identifier=0;
+				port->next_port_in_aggregator = NULL;
+				port->actor_port_aggregator_identifier = 0;
 
 				pr_debug("Port %d left LAG %d\n",
 					 port->actor_port_number,
@@ -1334,7 +1342,7 @@ static void ad_port_selection_logic(struct port *port)
 		// keep a free aggregator for later use(if needed)
 		if (!aggregator->lag_ports) {
 			if (!free_aggregator) {
-				free_aggregator=aggregator;
+				free_aggregator = aggregator;
 			}
 			continue;
 		}
@@ -1350,10 +1358,11 @@ static void ad_port_selection_logic(struct port *port)
 		   ) {
 			// attach to the founded aggregator
 			port->aggregator = aggregator;
-			port->actor_port_aggregator_identifier=port->aggregator->aggregator_identifier;
-			port->next_port_in_aggregator=aggregator->lag_ports;
+			port->actor_port_aggregator_identifier =
+				port->aggregator->aggregator_identifier;
+			port->next_port_in_aggregator = aggregator->lag_ports;
 			port->aggregator->num_of_ports++;
-			aggregator->lag_ports=port;
+			aggregator->lag_ports = port;
 			pr_debug("Port %d joined LAG %d(existing LAG)\n",
 				 port->actor_port_number,
 				 port->aggregator->aggregator_identifier);
@@ -1370,7 +1379,8 @@ static void ad_port_selection_logic(struct port *port)
 		if (free_aggregator) {
 			// assign port a new aggregator
 			port->aggregator = free_aggregator;
-			port->actor_port_aggregator_identifier=port->aggregator->aggregator_identifier;
+			port->actor_port_aggregator_identifier =
+				port->aggregator->aggregator_identifier;
 
 			// update the new aggregator's parameters
 			// if port was responsed from the end-user
@@ -1382,8 +1392,10 @@ static void ad_port_selection_logic(struct port *port)
 
 			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
 			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
-			port->aggregator->partner_system=port->partner_oper.system;
-			port->aggregator->partner_system_priority = port->partner_oper.system_priority;
+			port->aggregator->partner_system =
+				port->partner_oper.system;
+			port->aggregator->partner_system_priority =
+				port->partner_oper.system_priority;
 			port->aggregator->partner_oper_aggregator_key = port->partner_oper.key;
 			port->aggregator->receive_state = 1;
 			port->aggregator->transmit_state = 1;
@@ -1785,13 +1797,16 @@ static void ad_marker_info_send(struct port *port)
 	marker.requester_port = (((port->actor_port_number & 0xFF) << 8) |((u16)(port->actor_port_number & 0xFF00) >> 8));
 	marker.requester_system = port->actor_system;
 	// convert requester_port(u32) to Big Endian
-	marker.requester_transaction_id = (((++port->transaction_id & 0xFF) << 24) |((port->transaction_id & 0xFF00) << 8) |((port->transaction_id & 0xFF0000) >> 8) |((port->transaction_id & 0xFF000000) >> 24));
+	marker.requester_transaction_id =
+		(((++port->transaction_id & 0xFF) << 24)
+		 | ((port->transaction_id & 0xFF00) << 8)
+		 | ((port->transaction_id & 0xFF0000) >> 8)
+		 | ((port->transaction_id & 0xFF000000) >> 24));
 	marker.pad = 0;
 	marker.tlv_type_terminator = 0x00;
 	marker.terminator_length = 0x00;
-	for (index=0; index<90; index++) {
-		marker.reserved_90[index]=0;
-	}
+	for (index = 0; index < 90; index++)
+		marker.reserved_90[index] = 0;
 
 	// send the marker information
 	if (ad_marker_send(port, &marker) >= 0) {
@@ -1816,7 +1831,7 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 	//marker = *marker_info;
 	memcpy(&marker, marker_info, sizeof(struct bond_marker));
 	// change the marker subtype to marker response
-	marker.tlv_type=AD_MARKER_RESPONSE_SUBTYPE;
+	marker.tlv_type = AD_MARKER_RESPONSE_SUBTYPE;
 	// send the marker response
 
 	if (ad_marker_send(port, &marker) >= 0) {
@@ -1837,8 +1852,8 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 static void ad_marker_response_received(struct bond_marker *marker,
 	struct port *port)
 {
-	marker=NULL; // just to satisfy the compiler
-	port=NULL;  // just to satisfy the compiler
+	marker = NULL; /* just to satisfy the compiler */
+	port = NULL;  /* just to satisfy the compiler */
 	// DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW
 }
 
@@ -2037,8 +2052,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				new_aggregator->num_of_ports = aggregator->num_of_ports;
 
 				// update the information that is written on the ports about the aggregator
-				for (temp_port=aggregator->lag_ports; temp_port; temp_port=temp_port->next_port_in_aggregator) {
-					temp_port->aggregator=new_aggregator;
+				for (temp_port = aggregator->lag_ports; temp_port;
+				     temp_port = temp_port->next_port_in_aggregator) {
+					temp_port->aggregator = new_aggregator;
 					temp_port->actor_port_aggregator_identifier = new_aggregator->aggregator_identifier;
 				}
 
@@ -2071,7 +2087,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	for (; temp_aggregator; temp_aggregator = __get_next_agg(temp_aggregator)) {
 		prev_port = NULL;
 		// search the port in the aggregator's related ports
-		for (temp_port=temp_aggregator->lag_ports; temp_port; prev_port=temp_port, temp_port=temp_port->next_port_in_aggregator) {
+		for (temp_port = temp_aggregator->lag_ports; temp_port;
+		     prev_port = temp_port,
+			     temp_port = temp_port->next_port_in_aggregator) {
 			if (temp_port == port) { // the aggregator found - detach the port from this aggregator
 				if (prev_port) {
 					prev_port->next_port_in_aggregator = temp_port->next_port_in_aggregator;
@@ -2079,7 +2097,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					temp_aggregator->lag_ports = temp_port->next_port_in_aggregator;
 				}
 				temp_aggregator->num_of_ports--;
-				if (temp_aggregator->num_of_ports==0) {
+				if (temp_aggregator->num_of_ports == 0) {
 					select_new_active_agg = temp_aggregator->is_active;
 					// clear the aggregator
 					ad_clear_agg(temp_aggregator);
@@ -2094,7 +2112,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			}
 		}
 	}
-	port->slave=NULL;
+	port->slave = NULL;
 }
 
 /**
@@ -2245,7 +2263,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 	}
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
-	port->actor_oper_port_key=port->actor_admin_port_key |= (__get_link_speed(port) << 1);
+	port->actor_oper_port_key = port->actor_admin_port_key |=
+		(__get_link_speed(port) << 1);
 	pr_debug("Port %d changed speed\n", port->actor_port_number);
 	// there is no need to reselect a new aggregator, just signal the
 	// state machines to reinitialize
@@ -2262,7 +2281,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 {
 	struct port *port;
 
-	port=&(SLAVE_AD_INFO(slave).port);
+	port = &(SLAVE_AD_INFO(slave).port);
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
@@ -2272,7 +2291,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	}
 
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
-	port->actor_oper_port_key=port->actor_admin_port_key |= __get_duplex(port);
+	port->actor_oper_port_key = port->actor_admin_port_key |=
+		__get_duplex(port);
 	pr_debug("Port %d changed duplex\n", port->actor_port_number);
 	// there is no need to reselect a new aggregator, just signal the
 	// state machines to reinitialize
@@ -2304,14 +2324,17 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
-		port->actor_oper_port_key=port->actor_admin_port_key |= __get_duplex(port);
+		port->actor_oper_port_key = port->actor_admin_port_key |=
+			__get_duplex(port);
 		port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
-		port->actor_oper_port_key=port->actor_admin_port_key |= (__get_link_speed(port) << 1);
+		port->actor_oper_port_key = port->actor_admin_port_key |=
+			(__get_link_speed(port) << 1);
 	} else {
 		/* link has failed */
 		port->is_enabled = false;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
-		port->actor_oper_port_key= (port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS);
+		port->actor_oper_port_key = (port->actor_admin_port_key &=
+					     ~AD_SPEED_KEY_BITS);
 	}
 	//BOND_PRINT_DBG(("Port %d changed link status to %s", port->actor_port_number, ((link == BOND_LINK_UP)?"UP":"DOWN")));
 	// there is no need to reselect a new aggregator, just signal the
-- 
1.7.2.3
