From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/3] bonding: clean up style for bond_3ad.c
Date: Wed,  8 Jan 2014 16:46:46 +0100
Message-ID: <1389196008-28578-2-git-send-email-vfalico@redhat.com>
References: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755850AbaAHPvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 10:51:04 -0500
In-Reply-To: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a huge mess currently, that is really hard to read. This cleanup
doesn't touch the logic at all, it only breaks easy-to-fix long lines and
updates comment styles.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 619 +++++++++++++++++++++++------------------
 1 file changed, 349 insertions(+), 270 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 539e24a..9828209 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -34,14 +34,14 @@
 #include "bonding.h"
 #include "bond_3ad.h"
 
-// General definitions
+/* General definitions */
 #define AD_SHORT_TIMEOUT           1
 #define AD_LONG_TIMEOUT            0
 #define AD_STANDBY                 0x2
 #define AD_MAX_TX_IN_SECOND        3
 #define AD_COLLECTOR_MAX_DELAY     0
 
-// Timer definitions(43.4.4 in the 802.3ad standard)
+/* Timer definitions (43.4.4 in the 802.3ad standard) */
 #define AD_FAST_PERIODIC_TIME      1
 #define AD_SLOW_PERIODIC_TIME      30
 #define AD_SHORT_TIMEOUT_TIME      (3*AD_FAST_PERIODIC_TIME)
@@ -49,7 +49,7 @@
 #define AD_CHURN_DETECTION_TIME    60
 #define AD_AGGREGATE_WAIT_TIME     2
 
-// Port state definitions(43.4.2.2 in the 802.3ad standard)
+/* Port state definitions (43.4.2.2 in the 802.3ad standard) */
 #define AD_STATE_LACP_ACTIVITY   0x1
 #define AD_STATE_LACP_TIMEOUT    0x2
 #define AD_STATE_AGGREGATION     0x4
@@ -59,7 +59,9 @@
 #define AD_STATE_DEFAULTED       0x40
 #define AD_STATE_EXPIRED         0x80
 
-// Port Variables definitions used by the State Machines(43.4.7 in the 802.3ad standard)
+/* Port Variables definitions used by the State Machines (43.4.7 in the
+ * 802.3ad standard)
+ */
 #define AD_PORT_BEGIN           0x1
 #define AD_PORT_LACP_ENABLED    0x2
 #define AD_PORT_ACTOR_CHURN     0x4
@@ -71,24 +73,23 @@
 #define AD_PORT_SELECTED        0x100
 #define AD_PORT_MOVED           0x200
 
-// Port Key definitions
-// key is determined according to the link speed, duplex and
-// user key(which is yet not supported)
-//              ------------------------------------------------------------
-// Port key :   | User key                       |      Speed       |Duplex|
-//              ------------------------------------------------------------
-//              16                               6               1 0
+/* Port Key definitions
+ * key is determined according to the link speed, duplex and
+ * user key (which is yet not supported)
+ * --------------------------------------------------------------
+ * Port key :	| User key	| Speed		| Duplex	|
+ * --------------------------------------------------------------
+ * 16		  6		  1		  0
+ */
 #define  AD_DUPLEX_KEY_BITS    0x1
 #define  AD_SPEED_KEY_BITS     0x3E
 #define  AD_USER_KEY_BITS      0xFFC0
 
-//dalloun
 #define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
 #define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
-//endalloun
 
 /* compare MAC addresses */
 #define MAC_ADDRESS_EQUAL(A, B)	\
@@ -100,7 +101,7 @@ static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
 
 static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
-// ================= main 802.3ad protocol functions ==================
+/* ================= main 802.3ad protocol functions ================== */
 static int ad_lacpdu_send(struct port *port);
 static int ad_marker_send(struct port *port, struct bond_marker *marker);
 static void ad_mux_machine(struct port *port);
@@ -114,13 +115,13 @@ static void ad_initialize_agg(struct aggregator *aggregator);
 static void ad_initialize_port(struct port *port, int lacp_fast);
 static void ad_enable_collecting_distributing(struct port *port);
 static void ad_disable_collecting_distributing(struct port *port);
-static void ad_marker_info_received(struct bond_marker *marker_info, struct port *port);
-static void ad_marker_response_received(struct bond_marker *marker, struct port *port);
+static void ad_marker_info_received(struct bond_marker *marker_info,
+				    struct port *port);
+static void ad_marker_response_received(struct bond_marker *marker,
+					struct port *port);
 
 
-/////////////////////////////////////////////////////////////////////////////////
-// ================= api to bonding and kernel code ==================
-/////////////////////////////////////////////////////////////////////////////////
+/* ================= api to bonding and kernel code ================== */
 
 /**
  * __get_bond_by_port - get the port's bonding struct
@@ -151,17 +152,20 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 	/* If there's no bond for this port, or bond has no slaves */
 	if (bond == NULL)
 		return NULL;
+
 	rcu_read_lock();
 	first_slave = bond_first_slave_rcu(bond);
 	rcu_read_unlock();
+
 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 }
 
-/*
- * __agg_has_partner
+/**
+ * __agg_has_partner - see if we have a partner
+ * @agg: the agregator we're looking at
  *
  * Return nonzero if aggregator has a partner (denoted by a non-zero ether
- * address for the partner).  Return 0 if not.
+ * address for the partner). Return 0 if not.
  */
 static inline int __agg_has_partner(struct aggregator *agg)
 {
@@ -171,7 +175,6 @@ static inline int __agg_has_partner(struct aggregator *agg)
 /**
  * __disable_port - disable the port's slave
  * @port: the port we're looking at
- *
  */
 static inline void __disable_port(struct port *port)
 {
@@ -181,7 +184,6 @@ static inline void __disable_port(struct port *port)
 /**
  * __enable_port - enable the port's slave, if it's up
  * @port: the port we're looking at
- *
  */
 static inline void __enable_port(struct port *port)
 {
@@ -194,7 +196,6 @@ static inline void __enable_port(struct port *port)
 /**
  * __port_is_enabled - check if the port's slave is in active state
  * @port: the port we're looking at
- *
  */
 static inline int __port_is_enabled(struct port *port)
 {
@@ -220,7 +221,6 @@ static inline u32 __get_agg_selection_mode(struct port *port)
 /**
  * __check_agg_selection_timer - check if the selection timer has expired
  * @port: the port we're looking at
- *
  */
 static inline int __check_agg_selection_timer(struct port *port)
 {
@@ -235,7 +235,6 @@ static inline int __check_agg_selection_timer(struct port *port)
 /**
  * __get_state_machine_lock - lock the port's state machines
  * @port: the port we're looking at
- *
  */
 static inline void __get_state_machine_lock(struct port *port)
 {
@@ -245,7 +244,6 @@ static inline void __get_state_machine_lock(struct port *port)
 /**
  * __release_state_machine_lock - unlock the port's state machines
  * @port: the port we're looking at
- *
  */
 static inline void __release_state_machine_lock(struct port *port)
 {
@@ -268,10 +266,11 @@ static u16 __get_link_speed(struct port *port)
 	struct slave *slave = port->slave;
 	u16 speed;
 
-	/* this if covers only a special case: when the configuration starts with
-	 * link down, it sets the speed to 0.
-	 * This is done in spite of the fact that the e100 driver reports 0 to be
-	 * compatible with MVT in the future.*/
+	/* this if covers only a special case: when the configuration starts
+	 * with link down, it sets the speed to 0.
+	 * This is done in spite of the fact that the e100 driver reports 0
+	 * to be compatible with MVT in the future.
+	 */
 	if (slave->link != BOND_LINK_UP)
 		speed = 0;
 	else {
@@ -293,7 +292,8 @@ static u16 __get_link_speed(struct port *port)
 			break;
 
 		default:
-			speed = 0; // unknown speed value from ethtool. shouldn't happen
+			/* unknown speed value from ethtool. shouldn't happen */
+			speed = 0;
 			break;
 		}
 	}
@@ -317,8 +317,9 @@ static u8 __get_duplex(struct port *port)
 
 	u8 retval;
 
-	//  handling a special case: when the configuration starts with
-	// link down, it sets the duplex to 0.
+	/* handling a special case: when the configuration starts with
+	 * link down, it sets the duplex to 0.
+	 */
 	if (slave->link != BOND_LINK_UP)
 		retval = 0x0;
 	else {
@@ -342,15 +343,14 @@ static u8 __get_duplex(struct port *port)
 /**
  * __initialize_port_locks - initialize a port's STATE machine spinlock
  * @port: the slave of the port we're looking at
- *
  */
 static inline void __initialize_port_locks(struct slave *slave)
 {
-	// make sure it isn't called twice
+	/* make sure it isn't called twice */
 	spin_lock_init(&(SLAVE_AD_INFO(slave).state_machine_lock));
 }
 
-//conversions
+/* Conversions */
 
 /**
  * __ad_timer_to_ticks - convert a given timer type to AD module ticks
@@ -359,39 +359,38 @@ static inline void __initialize_port_locks(struct slave *slave)
  *
  * If @timer_type is %current_while_timer, @par indicates long/short timer.
  * If @timer_type is %periodic_timer, @par is one of %FAST_PERIODIC_TIME,
- *						    %SLOW_PERIODIC_TIME.
+ *						     %SLOW_PERIODIC_TIME.
  */
 static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
 {
 	u16 retval = 0; /* to silence the compiler */
 
 	switch (timer_type) {
-	case AD_CURRENT_WHILE_TIMER:   // for rx machine usage
+	case AD_CURRENT_WHILE_TIMER:	/* for rx machine usage */
 		if (par)
-			retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec); // short timeout
+			retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec);
 		else
-			retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec); // long timeout
+			retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec);
 		break;
-	case AD_ACTOR_CHURN_TIMER:	    // for local churn machine
+	case AD_ACTOR_CHURN_TIMER:	/* for local churn machine */
 		retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
 		break;
-	case AD_PERIODIC_TIMER:	    // for periodic machine
-		retval = (par*ad_ticks_per_sec); // long timeout
+	case AD_PERIODIC_TIMER:		/* for periodic machine */
+		retval = (par*ad_ticks_per_sec); /* long timeout */
 		break;
-	case AD_PARTNER_CHURN_TIMER:   // for remote churn machine
+	case AD_PARTNER_CHURN_TIMER:	/* for remote churn machine */
 		retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
 		break;
-	case AD_WAIT_WHILE_TIMER:	    // for selection machine
+	case AD_WAIT_WHILE_TIMER:	/* for selection machine */
 		retval = (AD_AGGREGATE_WAIT_TIME*ad_ticks_per_sec);
 		break;
 	}
+
 	return retval;
 }
 
 
-/////////////////////////////////////////////////////////////////////////////////
-// ================= ad_rx_machine helper functions ==================
-/////////////////////////////////////////////////////////////////////////////////
+/* ================= ad_rx_machine helper functions ================== */
 
 /**
  * __choose_matched - update a port's matched variable from a received lacpdu
@@ -451,7 +450,9 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		struct port_params *partner = &port->partner_oper;
 
 		__choose_matched(lacpdu, port);
-		// record the new parameter values for the partner operational
+		/* record the new parameter values for the partner
+		 * operational
+		 */
 		partner->port_number = ntohs(lacpdu->actor_port);
 		partner->port_priority = ntohs(lacpdu->actor_port_priority);
 		partner->system = lacpdu->actor_system;
@@ -459,10 +460,12 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 		partner->key = ntohs(lacpdu->actor_key);
 		partner->port_state = lacpdu->actor_state;
 
-		// set actor_oper_port_state.defaulted to FALSE
+		/* set actor_oper_port_state.defaulted to FALSE */
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;
 
-		// set the partner sync. to on if the partner is sync. and the port is matched
+		/* set the partner sync. to on if the partner is sync,
+		 * and the port is matched
+		 */
 		if ((port->sm_vars & AD_PORT_MATCHED)
 		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
 			partner->port_state |= AD_STATE_SYNCHRONIZATION;
@@ -482,11 +485,11 @@ static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 static void __record_default(struct port *port)
 {
 	if (port) {
-		// record the partner admin parameters
+		/* record the partner admin parameters */
 		memcpy(&port->partner_oper, &port->partner_admin,
 		       sizeof(struct port_params));
 
-		// set actor_oper_port_state.defaulted to true
+		/* set actor_oper_port_state.defaulted to true */
 		port->actor_oper_port_state |= AD_STATE_DEFAULTED;
 	}
 }
@@ -601,8 +604,10 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 static void __attach_bond_to_agg(struct port *port)
 {
 	port = NULL; /* just to satisfy the compiler */
-	// This function does nothing since the parser/multiplexer of the receive
-	// and the parser/multiplexer of the aggregator are already combined
+	/* This function does nothing since the parser/multiplexer of the
+	 * receive and the parser/multiplexer of the aggregator are already
+	 * combined.
+	 */
 }
 
 /**
@@ -616,8 +621,10 @@ static void __attach_bond_to_agg(struct port *port)
 static void __detach_bond_from_agg(struct port *port)
 {
 	port = NULL; /* just to satisfy the compiler */
-	// This function does nothing since the parser/multiplexer of the receive
-	// and the parser/multiplexer of the aggregator are already combined
+	/* This function does nothing since the parser/multiplexer of the
+	 * receive and the parser/multiplexer of the aggregator are already
+	 * combined
+	 */
 }
 
 /**
@@ -631,7 +638,9 @@ static int __agg_ports_are_ready(struct aggregator *aggregator)
 	int retval = 1;
 
 	if (aggregator) {
-		// scan all ports in this aggregator to verfy if they are all ready
+		/* scan all ports in this aggregator to verfy if they are
+		 * all ready.
+		 */
 		for (port = aggregator->lag_ports;
 		     port;
 		     port = port->next_port_in_aggregator) {
@@ -691,7 +700,7 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
 		default:
-			bandwidth = 0; /*to silence the compiler ....*/
+			bandwidth = 0; /* to silence the compiler */
 		}
 	}
 	return bandwidth;
@@ -700,7 +709,6 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 /**
  * __get_active_agg - get the current active aggregator
  * @aggregator: the aggregator we're looking at
- *
  */
 static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 {
@@ -722,15 +730,14 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 /**
  * __update_lacpdu_from_port - update a port's lacpdu fields
  * @port: the port we're looking at
- *
  */
 static inline void __update_lacpdu_from_port(struct port *port)
 {
 	struct lacpdu *lacpdu = &port->lacpdu;
 	const struct port_params *partner = &port->partner_oper;
 
-	/* update current actual Actor parameters */
-	/* lacpdu->subtype                   initialized
+	/* update current actual Actor parameters
+	 * lacpdu->subtype                   initialized
 	 * lacpdu->version_number            initialized
 	 * lacpdu->tlv_type_actor_info       initialized
 	 * lacpdu->actor_information_length  initialized
@@ -766,9 +773,7 @@ static inline void __update_lacpdu_from_port(struct port *port)
 	 */
 }
 
-//////////////////////////////////////////////////////////////////////////////////////
-// ================= main 802.3ad protocol code ======================================
-//////////////////////////////////////////////////////////////////////////////////////
+/* ================= main 802.3ad protocol code ========================= */
 
 /**
  * ad_lacpdu_send - send out a lacpdu packet on a given port
@@ -798,11 +803,12 @@ static int ad_lacpdu_send(struct port *port)
 
 	memcpy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source address is set to be the member's PERMANENT address,
-	   because we use it to identify loopback lacpdus in receive. */
+	 * because we use it to identify loopback lacpdus in receive.
+	 */
 	memcpy(lacpdu_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
 	lacpdu_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	lacpdu_header->lacpdu = port->lacpdu; // struct copy
+	lacpdu_header->lacpdu = port->lacpdu;
 
 	dev_queue_xmit(skb);
 
@@ -839,11 +845,12 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 
 	memcpy(marker_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
 	/* Note: source address is set to be the member's PERMANENT address,
-	   because we use it to identify loopback MARKERs in receive. */
+	 * because we use it to identify loopback MARKERs in receive.
+	 */
 	memcpy(marker_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
 	marker_header->hdr.h_proto = PKT_TYPE_LACPDU;
 
-	marker_header->marker = *marker; // struct copy
+	marker_header->marker = *marker;
 
 	dev_queue_xmit(skb);
 
@@ -853,72 +860,90 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
 /**
  * ad_mux_machine - handle a port's mux state machine
  * @port: the port we're looking at
- *
  */
 static void ad_mux_machine(struct port *port)
 {
 	mux_states_t last_state;
 
-	// keep current State Machine state to compare later if it was changed
+	/* keep current State Machine state to compare later if it was
+	 * changed
+	 */
 	last_state = port->sm_mux_state;
 
 	if (port->sm_vars & AD_PORT_BEGIN) {
-		port->sm_mux_state = AD_MUX_DETACHED;		 // next state
+		port->sm_mux_state = AD_MUX_DETACHED;
 	} else {
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
 			if ((port->sm_vars & AD_PORT_SELECTED)
 			    || (port->sm_vars & AD_PORT_STANDBY))
 				/* if SELECTED or STANDBY */
-				port->sm_mux_state = AD_MUX_WAITING; // next state
+				port->sm_mux_state = AD_MUX_WAITING;
 			break;
 		case AD_MUX_WAITING:
-			// if SELECTED == FALSE return to DETACH state
-			if (!(port->sm_vars & AD_PORT_SELECTED)) { // if UNSELECTED
+			/* if SELECTED == FALSE return to DETACH state */
+			if (!(port->sm_vars & AD_PORT_SELECTED)) {
 				port->sm_vars &= ~AD_PORT_READY_N;
-				// in order to withhold the Selection Logic to check all ports READY_N value
-				// every callback cycle to update ready variable, we check READY_N and update READY here
+				/* in order to withhold the Selection Logic to
+				 * check all ports READY_N value every callback
+				 * cycle to update ready variable, we check
+				 * READY_N and update READY here
+				 */
 				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
-				port->sm_mux_state = AD_MUX_DETACHED;	 // next state
+				port->sm_mux_state = AD_MUX_DETACHED;
 				break;
 			}
 
-			// check if the wait_while_timer expired
+			/* check if the wait_while_timer expired */
 			if (port->sm_mux_timer_counter
 			    && !(--port->sm_mux_timer_counter))
 				port->sm_vars |= AD_PORT_READY_N;
 
-			// in order to withhold the selection logic to check all ports READY_N value
-			// every callback cycle to update ready variable, we check READY_N and update READY here
+			/* in order to withhold the selection logic to check
+			 * all ports READY_N value every callback cycle to
+			 * update ready variable, we check READY_N and update
+			 * READY here
+			 */
 			__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
 
-			// if the wait_while_timer expired, and the port is in READY state, move to ATTACHED state
+			/* if the wait_while_timer expired, and the port is
+			 * in READY state, move to ATTACHED state
+			 */
 			if ((port->sm_vars & AD_PORT_READY)
 			    && !port->sm_mux_timer_counter)
-				port->sm_mux_state = AD_MUX_ATTACHED;	 // next state
+				port->sm_mux_state = AD_MUX_ATTACHED;
 			break;
 		case AD_MUX_ATTACHED:
-			// check also if agg_select_timer expired(so the edable port will take place only after this timer)
-			if ((port->sm_vars & AD_PORT_SELECTED) && (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) && !__check_agg_selection_timer(port)) {
-				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;// next state
-			} else if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY)) {	  // if UNSELECTED or STANDBY
+			/* check also if agg_select_timer expired (so the
+			 * edable port will take place only after this timer)
+			 */
+			if ((port->sm_vars & AD_PORT_SELECTED) &&
+			    (port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION) &&
+			    !__check_agg_selection_timer(port)) {
+				port->sm_mux_state = AD_MUX_COLLECTING_DISTRIBUTING;
+			} else if (!(port->sm_vars & AD_PORT_SELECTED) ||
+				   (port->sm_vars & AD_PORT_STANDBY)) {
+				/* if UNSELECTED or STANDBY */
 				port->sm_vars &= ~AD_PORT_READY_N;
-				// in order to withhold the selection logic to check all ports READY_N value
-				// every callback cycle to update ready variable, we check READY_N and update READY here
+				/* in order to withhold the selection logic to
+				 * check all ports READY_N value every callback
+				 * cycle to update ready variable, we check
+				 * READY_N and update READY here
+				 */
 				__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
-				port->sm_mux_state = AD_MUX_DETACHED;// next state
+				port->sm_mux_state = AD_MUX_DETACHED;
 			}
 			break;
 		case AD_MUX_COLLECTING_DISTRIBUTING:
-			if (!(port->sm_vars & AD_PORT_SELECTED) || (port->sm_vars & AD_PORT_STANDBY) ||
-			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)
-			   ) {
-				port->sm_mux_state = AD_MUX_ATTACHED;// next state
-
+			if (!(port->sm_vars & AD_PORT_SELECTED) ||
+			    (port->sm_vars & AD_PORT_STANDBY) ||
+			    !(port->partner_oper.port_state & AD_STATE_SYNCHRONIZATION)) {
+				port->sm_mux_state = AD_MUX_ATTACHED;
 			} else {
-				// if port state hasn't changed make
-				// sure that a collecting distributing
-				// port in an active aggregator is enabled
+				/* if port state hasn't changed make
+				 * sure that a collecting distributing
+				 * port in an active aggregator is enabled
+				 */
 				if (port->aggregator &&
 				    port->aggregator->is_active &&
 				    !__port_is_enabled(port)) {
@@ -927,12 +952,12 @@ static void ad_mux_machine(struct port *port)
 				}
 			}
 			break;
-		default:    //to silence the compiler
+		default:
 			break;
 		}
 	}
 
-	// check if the state machine was changed
+	/* check if the state machine was changed */
 	if (port->sm_mux_state != last_state) {
 		pr_debug("Mux Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
@@ -963,7 +988,7 @@ static void ad_mux_machine(struct port *port)
 			ad_enable_collecting_distributing(port);
 			port->ntt = true;
 			break;
-		default:    //to silence the compiler
+		default:
 			break;
 		}
 	}
@@ -982,59 +1007,63 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 {
 	rx_states_t last_state;
 
-	// keep current State Machine state to compare later if it was changed
+	/* keep current State Machine state to compare later if it was
+	 * changed
+	 */
 	last_state = port->sm_rx_state;
 
-	// check if state machine should change state
-	// first, check if port was reinitialized
+	/* check if state machine should change state */
+
+	/* first, check if port was reinitialized */
 	if (port->sm_vars & AD_PORT_BEGIN)
-		/* next state */
 		port->sm_rx_state = AD_RX_INITIALIZE;
-	// check if port is not enabled
+	/* check if port is not enabled */
 	else if (!(port->sm_vars & AD_PORT_BEGIN)
 		 && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
-		/* next state */
 		port->sm_rx_state = AD_RX_PORT_DISABLED;
-	// check if new lacpdu arrived
-	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) || (port->sm_rx_state == AD_RX_DEFAULTED) || (port->sm_rx_state == AD_RX_CURRENT))) {
-		port->sm_rx_timer_counter = 0; // zero timer
+	/* check if new lacpdu arrived */
+	else if (lacpdu && ((port->sm_rx_state == AD_RX_EXPIRED) ||
+		 (port->sm_rx_state == AD_RX_DEFAULTED) ||
+		 (port->sm_rx_state == AD_RX_CURRENT))) {
+		port->sm_rx_timer_counter = 0;
 		port->sm_rx_state = AD_RX_CURRENT;
 	} else {
-		// if timer is on, and if it is expired
-		if (port->sm_rx_timer_counter && !(--port->sm_rx_timer_counter)) {
+		/* if timer is on, and if it is expired */
+		if (port->sm_rx_timer_counter &&
+		    !(--port->sm_rx_timer_counter)) {
 			switch (port->sm_rx_state) {
 			case AD_RX_EXPIRED:
-				port->sm_rx_state = AD_RX_DEFAULTED;		// next state
+				port->sm_rx_state = AD_RX_DEFAULTED;
 				break;
 			case AD_RX_CURRENT:
-				port->sm_rx_state = AD_RX_EXPIRED;	    // next state
+				port->sm_rx_state = AD_RX_EXPIRED;
 				break;
-			default:    //to silence the compiler
+			default:
 				break;
 			}
 		} else {
-			// if no lacpdu arrived and no timer is on
+			/* if no lacpdu arrived and no timer is on */
 			switch (port->sm_rx_state) {
 			case AD_RX_PORT_DISABLED:
 				if (port->sm_vars & AD_PORT_MOVED)
-					port->sm_rx_state = AD_RX_INITIALIZE;	    // next state
+					port->sm_rx_state = AD_RX_INITIALIZE;
 				else if (port->is_enabled
 					 && (port->sm_vars
 					     & AD_PORT_LACP_ENABLED))
-					port->sm_rx_state = AD_RX_EXPIRED;	// next state
+					port->sm_rx_state = AD_RX_EXPIRED;
 				else if (port->is_enabled
 					 && ((port->sm_vars
 					      & AD_PORT_LACP_ENABLED) == 0))
-					port->sm_rx_state = AD_RX_LACP_DISABLED;    // next state
+					port->sm_rx_state = AD_RX_LACP_DISABLED;
 				break;
-			default:    //to silence the compiler
+			default:
 				break;
 
 			}
 		}
 	}
 
-	// check if the State machine was changed or new lacpdu arrived
+	/* check if the State machine was changed or new lacpdu arrived */
 	if ((port->sm_rx_state != last_state) || (lacpdu)) {
 		pr_debug("Rx Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
@@ -1049,10 +1078,9 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			__record_default(port);
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			port->sm_vars &= ~AD_PORT_MOVED;
-			port->sm_rx_state = AD_RX_PORT_DISABLED;	// next state
-
-			/*- Fall Through -*/
+			port->sm_rx_state = AD_RX_PORT_DISABLED;
 
+			/* Fall Through */
 		case AD_RX_PORT_DISABLED:
 			port->sm_vars &= ~AD_PORT_MATCHED;
 			break;
@@ -1064,13 +1092,15 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
 		case AD_RX_EXPIRED:
-			//Reset of the Synchronization flag. (Standard 43.4.12)
-			//This reset cause to disable this port in the COLLECTING_DISTRIBUTING state of the
-			//mux machine in case of EXPIRED even if LINK_DOWN didn't arrive for the port.
+			/* Reset of the Synchronization flag (Standard 43.4.12)
+			 * This reset cause to disable this port in the
+			 * COLLECTING_DISTRIBUTING state of the mux machine in
+			 * case of EXPIRED even if LINK_DOWN didn't arrive for
+			 * the port.
+			 */
 			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
 			port->sm_vars &= ~AD_PORT_MATCHED;
-			port->partner_oper.port_state |=
-				AD_STATE_LACP_ACTIVITY;
+			port->partner_oper.port_state |= AD_STATE_LACP_ACTIVITY;
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
 			port->actor_oper_port_state |= AD_STATE_EXPIRED;
 			break;
@@ -1082,10 +1112,11 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			break;
 		case AD_RX_CURRENT:
 			/* detect loopback situation */
-			if (MAC_ADDRESS_EQUAL(&(lacpdu->actor_system), &(port->actor_system))) {
-				pr_err("%s: An illegal loopback occurred on adapter (%s).\n"
-				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
-				       port->slave->bond->dev->name, port->slave->dev->name);
+			if (MAC_ADDRESS_EQUAL(&(lacpdu->actor_system),
+					      &(port->actor_system))) {
+				pr_err("%s: An illegal loopback occurred on adapter (%s).\nCheck the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
+				       port->slave->bond->dev->name,
+				       port->slave->dev->name);
 				return;
 			}
 			__update_selected(lacpdu, port);
@@ -1094,7 +1125,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
 			break;
-		default:    /* to silence the compiler */
+		default:
 			break;
 		}
 	}
@@ -1103,13 +1134,14 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 /**
  * ad_tx_machine - handle a port's tx state machine
  * @port: the port we're looking at
- *
  */
 static void ad_tx_machine(struct port *port)
 {
-	// check if tx timer expired, to verify that we do not send more than 3 packets per second
+	/* check if tx timer expired, to verify that we do not send more than
+	 * 3 packets per second
+	 */
 	if (port->sm_tx_timer_counter && !(--port->sm_tx_timer_counter)) {
-		// check if there is something to send
+		/* check if there is something to send */
 		if (port->ntt && (port->sm_vars & AD_PORT_LACP_ENABLED)) {
 			__update_lacpdu_from_port(port);
 
@@ -1117,14 +1149,16 @@ static void ad_tx_machine(struct port *port)
 				pr_debug("Sent LACPDU on port %d\n",
 					 port->actor_port_number);
 
-				/* mark ntt as false, so it will not be sent again until
-				   demanded */
+				/* mark ntt as false, so it will not be sent
+				 * again until demanded
+				 */
 				port->ntt = false;
 			}
 		}
-		// restart tx timer(to verify that we will not exceed AD_MAX_TX_IN_SECOND
-		port->sm_tx_timer_counter =
-			ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
+		/* restart tx timer(to verify that we will not exceed
+		 * AD_MAX_TX_IN_SECOND
+		 */
+		port->sm_tx_timer_counter = ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 	}
 }
 
@@ -1138,76 +1172,79 @@ static void ad_periodic_machine(struct port *port)
 {
 	periodic_states_t last_state;
 
-	// keep current state machine state to compare later if it was changed
+	/* keep current state machine state to compare later if it was changed */
 	last_state = port->sm_periodic_state;
 
-	// check if port was reinitialized
+	/* check if port was reinitialized */
 	if (((port->sm_vars & AD_PORT_BEGIN) || !(port->sm_vars & AD_PORT_LACP_ENABLED) || !port->is_enabled) ||
 	    (!(port->actor_oper_port_state & AD_STATE_LACP_ACTIVITY) && !(port->partner_oper.port_state & AD_STATE_LACP_ACTIVITY))
 	   ) {
-		port->sm_periodic_state = AD_NO_PERIODIC;	     // next state
+		port->sm_periodic_state = AD_NO_PERIODIC;
 	}
-	// check if state machine should change state
+	/* check if state machine should change state */
 	else if (port->sm_periodic_timer_counter) {
-		// check if periodic state machine expired
+		/* check if periodic state machine expired */
 		if (!(--port->sm_periodic_timer_counter)) {
-			// if expired then do tx
-			port->sm_periodic_state = AD_PERIODIC_TX;    // next state
+			/* if expired then do tx */
+			port->sm_periodic_state = AD_PERIODIC_TX;
 		} else {
-			// If not expired, check if there is some new timeout parameter from the partner state
+			/* If not expired, check if there is some new timeout
+			 * parameter from the partner state
+			 */
 			switch (port->sm_periodic_state) {
 			case AD_FAST_PERIODIC:
 				if (!(port->partner_oper.port_state
 				      & AD_STATE_LACP_TIMEOUT))
-					port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
+					port->sm_periodic_state = AD_SLOW_PERIODIC;
 				break;
 			case AD_SLOW_PERIODIC:
 				if ((port->partner_oper.port_state & AD_STATE_LACP_TIMEOUT)) {
-					// stop current timer
 					port->sm_periodic_timer_counter = 0;
-					port->sm_periodic_state = AD_PERIODIC_TX;	 // next state
+					port->sm_periodic_state = AD_PERIODIC_TX;
 				}
 				break;
-			default:    //to silence the compiler
+			default:
 				break;
 			}
 		}
 	} else {
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
-			port->sm_periodic_state = AD_FAST_PERIODIC;	 // next state
+			port->sm_periodic_state = AD_FAST_PERIODIC;
 			break;
 		case AD_PERIODIC_TX:
-			if (!(port->partner_oper.port_state
-			      & AD_STATE_LACP_TIMEOUT))
-				port->sm_periodic_state = AD_SLOW_PERIODIC;  // next state
+			if (!(port->partner_oper.port_state &
+			    AD_STATE_LACP_TIMEOUT))
+				port->sm_periodic_state = AD_SLOW_PERIODIC;
 			else
-				port->sm_periodic_state = AD_FAST_PERIODIC;  // next state
+				port->sm_periodic_state = AD_FAST_PERIODIC;
 			break;
-		default:    //to silence the compiler
+		default:
 			break;
 		}
 	}
 
-	// check if the state machine was changed
+	/* check if the state machine was changed */
 	if (port->sm_periodic_state != last_state) {
 		pr_debug("Periodic Machine: Port=%d, Last State=%d, Curr State=%d\n",
 			 port->actor_port_number, last_state,
 			 port->sm_periodic_state);
 		switch (port->sm_periodic_state) {
 		case AD_NO_PERIODIC:
-			port->sm_periodic_timer_counter = 0;	   // zero timer
+			port->sm_periodic_timer_counter = 0;
 			break;
 		case AD_FAST_PERIODIC:
-			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_FAST_PERIODIC_TIME))-1; // decrement 1 tick we lost in the PERIODIC_TX cycle
+			/* decrement 1 tick we lost in the PERIODIC_TX cycle */
+			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_FAST_PERIODIC_TIME))-1;
 			break;
 		case AD_SLOW_PERIODIC:
-			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_SLOW_PERIODIC_TIME))-1; // decrement 1 tick we lost in the PERIODIC_TX cycle
+			/* decrement 1 tick we lost in the PERIODIC_TX cycle */
+			port->sm_periodic_timer_counter = __ad_timer_to_ticks(AD_PERIODIC_TIMER, (u16)(AD_SLOW_PERIODIC_TIME))-1;
 			break;
 		case AD_PERIODIC_TX:
 			port->ntt = true;
 			break;
-		default:    //to silence the compiler
+		default:
 			break;
 		}
 	}
@@ -1230,30 +1267,38 @@ static void ad_port_selection_logic(struct port *port)
 	struct slave *slave;
 	int found = 0;
 
-	// if the port is already Selected, do nothing
+	/* if the port is already Selected, do nothing */
 	if (port->sm_vars & AD_PORT_SELECTED)
 		return;
 
 	bond = __get_bond_by_port(port);
 
-	// if the port is connected to other aggregator, detach it
+	/* if the port is connected to other aggregator, detach it */
 	if (port->aggregator) {
-		// detach the port from its former aggregator
+		/* detach the port from its former aggregator */
 		temp_aggregator = port->aggregator;
 		for (curr_port = temp_aggregator->lag_ports; curr_port;
 		     last_port = curr_port,
-			     curr_port = curr_port->next_port_in_aggregator) {
+		     curr_port = curr_port->next_port_in_aggregator) {
 			if (curr_port == port) {
 				temp_aggregator->num_of_ports--;
-				if (!last_port) {// if it is the first port attached to the aggregator
+				/* if it is the first port attached to the
+				 * aggregator
+				 */
+				if (!last_port) {
 					temp_aggregator->lag_ports =
 						port->next_port_in_aggregator;
-				} else {// not the first port attached to the aggregator
+				} else {
+					/* not the first port attached to the
+					 * aggregator
+					 */
 					last_port->next_port_in_aggregator =
 						port->next_port_in_aggregator;
 				}
 
-				// clear the port's relations to this aggregator
+				/* clear the port's relations to this
+				 * aggregator
+				 */
 				port->aggregator = NULL;
 				port->next_port_in_aggregator = NULL;
 				port->actor_port_aggregator_identifier = 0;
@@ -1261,13 +1306,18 @@ static void ad_port_selection_logic(struct port *port)
 				pr_debug("Port %d left LAG %d\n",
 					 port->actor_port_number,
 					 temp_aggregator->aggregator_identifier);
-				// if the aggregator is empty, clear its parameters, and set it ready to be attached
+				/* if the aggregator is empty, clear its
+				 * parameters, and set it ready to be attached
+				 */
 				if (!temp_aggregator->lag_ports)
 					ad_clear_agg(temp_aggregator);
 				break;
 			}
 		}
-		if (!curr_port) { // meaning: the port was related to an aggregator but was not on the aggregator port list
+		if (!curr_port) {
+			/* meaning: the port was related to an aggregator
+			 * but was not on the aggregator port list
+			 */
 			pr_warning("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
 				   port->slave->bond->dev->name,
 				   port->actor_port_number,
@@ -1275,11 +1325,11 @@ static void ad_port_selection_logic(struct port *port)
 				   port->aggregator->aggregator_identifier);
 		}
 	}
-	// search on all aggregators for a suitable aggregator for this port
+	/* search on all aggregators for a suitable aggregator for this port */
 	bond_for_each_slave(bond, slave, iter) {
 		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
 
-		// keep a free aggregator for later use(if needed)
+		/* keep a free aggregator for later use(if needed) */
 		if (!aggregator->lag_ports) {
 			if (!free_aggregator)
 				free_aggregator = aggregator;
@@ -1306,23 +1356,26 @@ static void ad_port_selection_logic(struct port *port)
 				 port->actor_port_number,
 				 port->aggregator->aggregator_identifier);
 
-			// mark this port as selected
+			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
 			found = 1;
 			break;
 		}
 	}
 
-	// the port couldn't find an aggregator - attach it to a new aggregator
+	/* the port couldn't find an aggregator - attach it to a new
+	 * aggregator
+	 */
 	if (!found) {
 		if (free_aggregator) {
-			// assign port a new aggregator
+			/* assign port a new aggregator */
 			port->aggregator = free_aggregator;
 			port->actor_port_aggregator_identifier =
 				port->aggregator->aggregator_identifier;
 
-			// update the new aggregator's parameters
-			// if port was responsed from the end-user
+			/* update the new aggregator's parameters
+			 * if port was responsed from the end-user
+			 */
 			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)
 				/* if port is full duplex */
 				port->aggregator->is_individual = false;
@@ -1341,7 +1394,7 @@ static void ad_port_selection_logic(struct port *port)
 			port->aggregator->lag_ports = port;
 			port->aggregator->num_of_ports++;
 
-			// mark this port as selected
+			/* mark this port as selected */
 			port->sm_vars |= AD_PORT_SELECTED;
 
 			pr_debug("Port %d joined LAG %d(new LAG)\n",
@@ -1353,23 +1406,24 @@ static void ad_port_selection_logic(struct port *port)
 			       port->actor_port_number, port->slave->dev->name);
 		}
 	}
-	// if all aggregator's ports are READY_N == TRUE, set ready=TRUE in all aggregator's ports
-	// else set ready=FALSE in all aggregator's ports
-	__set_agg_ports_ready(port->aggregator, __agg_ports_are_ready(port->aggregator));
+	/* if all aggregator's ports are READY_N == TRUE, set ready=TRUE
+	 * in all aggregator's ports, else set ready=FALSE in all
+	 * aggregator's ports
+	 */
+	__set_agg_ports_ready(port->aggregator,
+			      __agg_ports_are_ready(port->aggregator));
 
 	aggregator = __get_first_agg(port);
 	ad_agg_selection_logic(aggregator);
 }
 
-/*
- * Decide if "agg" is a better choice for the new active aggregator that
+/* Decide if "agg" is a better choice for the new active aggregator that
  * the current best, according to the ad_select policy.
  */
 static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 						struct aggregator *curr)
 {
-	/*
-	 * 0. If no best, select current.
+	/* 0. If no best, select current.
 	 *
 	 * 1. If the current agg is not individual, and the best is
 	 *    individual, select current.
@@ -1437,10 +1491,12 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 static int agg_device_up(const struct aggregator *agg)
 {
 	struct port *port = agg->lag_ports;
+
 	if (!port)
 		return 0;
-	return (netif_running(port->slave->dev) &&
-		netif_carrier_ok(port->slave->dev));
+
+	return netif_running(port->slave->dev) &&
+	       netif_carrier_ok(port->slave->dev);
 }
 
 /**
@@ -1492,8 +1548,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 
 	if (best &&
 	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
-		/*
-		 * For the STABLE policy, don't replace the old active
+		/* For the STABLE policy, don't replace the old active
 		 * aggregator if it's still active (it has an answering
 		 * partner) or if both the best and active don't have an
 		 * answering partner.
@@ -1501,7 +1556,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		if (active && active->lag_ports &&
 		    active->lag_ports->is_enabled &&
 		    (__agg_has_partner(active) ||
-		     (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
+		     (!__agg_has_partner(active) &&
+		     !__agg_has_partner(best)))) {
 			if (!(!active->actor_oper_aggregator_key &&
 			      best->actor_oper_aggregator_key)) {
 				best = NULL;
@@ -1552,7 +1608,9 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->partner_oper_aggregator_key,
 			 best->is_individual, best->is_active);
 
-		/* disable the ports that were related to the former active_aggregator */
+		/* disable the ports that were related to the former
+		 * active_aggregator
+		 */
 		if (active) {
 			for (port = active->lag_ports; port;
 			     port = port->next_port_in_aggregator) {
@@ -1561,8 +1619,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 	}
 
-	/*
-	 * if the selected aggregator is of join individuals
+	/* if the selected aggregator is of join individuals
 	 * (partner_system is NULL), enable their ports
 	 */
 	active = __get_active_agg(origin);
@@ -1584,7 +1641,6 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 /**
  * ad_clear_agg - clear a given aggregator's parameters
  * @aggregator: the aggregator we're looking at
- *
  */
 static void ad_clear_agg(struct aggregator *aggregator)
 {
@@ -1608,7 +1664,6 @@ static void ad_clear_agg(struct aggregator *aggregator)
 /**
  * ad_initialize_agg - initialize a given aggregator's parameters
  * @aggregator: the aggregator we're looking at
- *
  */
 static void ad_initialize_agg(struct aggregator *aggregator)
 {
@@ -1625,7 +1680,6 @@ static void ad_initialize_agg(struct aggregator *aggregator)
  * ad_initialize_port - initialize a given port's parameters
  * @aggregator: the aggregator we're looking at
  * @lacp_fast: boolean. whether fast periodic should be used
- *
  */
 static void ad_initialize_port(struct port *port, int lacp_fast)
 {
@@ -1657,8 +1711,10 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		port->ntt = false;
 		port->actor_admin_port_key = 1;
 		port->actor_oper_port_key  = 1;
-		port->actor_admin_port_state = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
-		port->actor_oper_port_state  = AD_STATE_AGGREGATION | AD_STATE_LACP_ACTIVITY;
+		port->actor_admin_port_state = AD_STATE_AGGREGATION |
+					       AD_STATE_LACP_ACTIVITY;
+		port->actor_oper_port_state  = AD_STATE_AGGREGATION |
+					       AD_STATE_LACP_ACTIVITY;
 
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
@@ -1667,7 +1723,7 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		memcpy(&port->partner_oper, &tmpl, sizeof(tmpl));
 
 		port->is_enabled = true;
-		// ****** private parameters ******
+		/* private parameters */
 		port->sm_vars = 0x3;
 		port->sm_rx_state = 0;
 		port->sm_rx_timer_counter = 0;
@@ -1705,11 +1761,12 @@ static void ad_enable_collecting_distributing(struct port *port)
 /**
  * ad_disable_collecting_distributing - disable a port's transmit/receive
  * @port: the port we're looking at
- *
  */
 static void ad_disable_collecting_distributing(struct port *port)
 {
-	if (port->aggregator && !MAC_ADDRESS_EQUAL(&(port->aggregator->partner_system), &(null_mac_addr))) {
+	if (port->aggregator &&
+	    !MAC_ADDRESS_EQUAL(&(port->aggregator->partner_system),
+			       &(null_mac_addr))) {
 		pr_debug("Disabling port %d(LAG %d)\n",
 			 port->actor_port_number,
 			 port->aggregator->aggregator_identifier);
@@ -1763,20 +1820,18 @@ static void ad_marker_info_send(struct port *port)
  * ad_marker_info_received - handle receive of a Marker information frame
  * @marker_info: Marker info received
  * @port: the port we're looking at
- *
  */
 static void ad_marker_info_received(struct bond_marker *marker_info,
 	struct port *port)
 {
 	struct bond_marker marker;
 
-	// copy the received marker data to the response marker
-	//marker = *marker_info;
+	/* copy the received marker data to the response marker */
 	memcpy(&marker, marker_info, sizeof(struct bond_marker));
-	// change the marker subtype to marker response
+	/* change the marker subtype to marker response */
 	marker.tlv_type = AD_MARKER_RESPONSE_SUBTYPE;
-	// send the marker response
 
+	/* send the marker response */
 	if (ad_marker_send(port, &marker) >= 0) {
 		pr_debug("Sent Marker Response on port %d\n",
 			 port->actor_port_number);
@@ -1793,22 +1848,21 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
  * information.
  */
 static void ad_marker_response_received(struct bond_marker *marker,
-	struct port *port)
+					struct port *port)
 {
-	marker = NULL; /* just to satisfy the compiler */
-	port = NULL;  /* just to satisfy the compiler */
-	// DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW
+	marker = NULL;
+	port = NULL;
+	/* DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW */
 }
 
-//////////////////////////////////////////////////////////////////////////////////////
-// ================= AD exported functions to the main bonding code ==================
-//////////////////////////////////////////////////////////////////////////////////////
+/* ========= AD exported functions to the main bonding code ========= */
 
-// Check aggregators status in team every T seconds
+/* Check aggregators status in team every T seconds */
 #define AD_AGGREGATOR_SELECTION_TIMER  8
 
-/*
- * bond_3ad_initiate_agg_selection(struct bonding *bond)
+/**
+ * bond_3ad_initiate_agg_selection - initate aggregator selection
+ * @bond: bonding struct
  *
  * Set the aggregation selection timer, to initiate an agg selection in
  * the very near future.  Called during first initialization, and during
@@ -1839,7 +1893,9 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
 		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
 
-		// initialize how many times this module is called in one second(should be about every 100ms)
+		/* initialize how many times this module is called in one
+		 * second (should be about every 100ms)
+		 */
 		ad_ticks_per_sec = tick_resolution;
 
 		bond_3ad_initiate_agg_selection(bond,
@@ -1874,21 +1930,21 @@ void bond_3ad_bind_slave(struct slave *slave)
 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
 		/* key is determined according to the link speed, duplex and user key(which
 		 * is yet not supported)
-		 *              ------------------------------------------------------------
-		 * Port key :   | User key                       |      Speed       |Duplex|
-		 *              ------------------------------------------------------------
-		 *              16                               6               1 0
 		 */
-		port->actor_admin_port_key = 0;	/* initialize this parameter */
+		port->actor_admin_port_key = 0;
 		port->actor_admin_port_key |= __get_duplex(port);
 		port->actor_admin_port_key |= (__get_link_speed(port) << 1);
 		port->actor_oper_port_key = port->actor_admin_port_key;
-		/* if the port is not full duplex, then the port should be not lacp Enabled */
+		/* if the port is not full duplex, then the port should be not
+		 * lacp Enabled
+		 */
 		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 		/* actor system is the bond's system */
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
-		/* tx timer(to verify that no more than MAX_TX_IN_SECOND lacpdu's are sent in one second) */
+		/* tx timer(to verify that no more than MAX_TX_IN_SECOND
+		 * lacpdu's are sent in one second)
+		 */
 		port->sm_tx_timer_counter = ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
 		port->aggregator = NULL;
 		port->next_port_in_aggregator = NULL;
@@ -1925,13 +1981,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct slave *slave_iter;
 	struct list_head *iter;
 
-	// find the aggregator related to this slave
 	aggregator = &(SLAVE_AD_INFO(slave).aggregator);
-
-	// find the port related to this slave
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: Trying to unbind an uninitialized port on %s\n",
 			   slave->bond->dev->name, slave->dev->name);
@@ -1946,34 +1999,42 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	__update_lacpdu_from_port(port);
 	ad_lacpdu_send(port);
 
-	// check if this aggregator is occupied
+	/* check if this aggregator is occupied */
 	if (aggregator->lag_ports) {
-		// check if there are other ports related to this aggregator except
-		// the port related to this slave(thats ensure us that there is a
-		// reason to search for new aggregator, and that we will find one
-		if ((aggregator->lag_ports != port) || (aggregator->lag_ports->next_port_in_aggregator)) {
-			// find new aggregator for the related port(s)
+		/* check if there are other ports related to this aggregator
+		 * except the port related to this slave(thats ensure us that
+		 * there is a reason to search for new aggregator, and that we
+		 * will find one
+		 */
+		if ((aggregator->lag_ports != port) ||
+		    (aggregator->lag_ports->next_port_in_aggregator)) {
+			/* find new aggregator for the related port(s) */
 			bond_for_each_slave(bond, slave_iter, iter) {
 				new_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
-				// if the new aggregator is empty, or it is connected to our port only
-				if (!new_aggregator->lag_ports
-				    || ((new_aggregator->lag_ports == port)
-					&& !new_aggregator->lag_ports->next_port_in_aggregator))
+				/* if the new aggregator is empty, or it is
+				 * connected to our port only
+				 */
+				if (!new_aggregator->lag_ports ||
+				    ((new_aggregator->lag_ports == port) &&
+				     !new_aggregator->lag_ports->next_port_in_aggregator))
 					break;
 			}
 			if (!slave_iter)
 				new_aggregator = NULL;
-			// if new aggregator found, copy the aggregator's parameters
-			// and connect the related lag_ports to the new aggregator
+
+			/* if new aggregator found, copy the aggregator's
+			 * parameters and connect the related lag_ports to the
+			 * new aggregator
+			 */
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
 				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n",
 					 aggregator->aggregator_identifier,
 					 new_aggregator->aggregator_identifier);
 
-				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
+				if ((new_aggregator->lag_ports == port) &&
+				    new_aggregator->is_active) {
 					pr_info("%s: Removing an active aggregator\n",
 						aggregator->slave->bond->dev->name);
-					// select new active aggregator
 					 select_new_active_agg = 1;
 				}
 
@@ -1989,14 +2050,15 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				new_aggregator->is_active = aggregator->is_active;
 				new_aggregator->num_of_ports = aggregator->num_of_ports;
 
-				// update the information that is written on the ports about the aggregator
+				/* update the information that is written on
+				 * the ports about the aggregator
+				 */
 				for (temp_port = aggregator->lag_ports; temp_port;
 				     temp_port = temp_port->next_port_in_aggregator) {
 					temp_port->aggregator = new_aggregator;
 					temp_port->actor_port_aggregator_identifier = new_aggregator->aggregator_identifier;
 				}
 
-				// clear the aggregator
 				ad_clear_agg(aggregator);
 
 				if (select_new_active_agg)
@@ -2005,14 +2067,16 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				pr_warning("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
 					   slave->bond->dev->name);
 			}
-		} else { // in case that the only port related to this aggregator is the one we want to remove
+		} else {
+			/* in case that the only port related to this
+			 * aggregator is the one we want to remove
+			 */
 			select_new_active_agg = aggregator->is_active;
-			// clear the aggregator
 			ad_clear_agg(aggregator);
 			if (select_new_active_agg) {
 				pr_info("%s: Removing an active aggregator\n",
 					slave->bond->dev->name);
-				// select new active aggregator
+				/* select new active aggregator */
 				temp_aggregator = __get_first_agg(port);
 				if (temp_aggregator)
 					ad_agg_selection_logic(temp_aggregator);
@@ -2021,15 +2085,19 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	}
 
 	pr_debug("Unbinding port %d\n", port->actor_port_number);
-	// find the aggregator that this port is connected to
+
+	/* find the aggregator that this port is connected to */
 	bond_for_each_slave(bond, slave_iter, iter) {
 		temp_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
 		prev_port = NULL;
-		// search the port in the aggregator's related ports
+		/* search the port in the aggregator's related ports */
 		for (temp_port = temp_aggregator->lag_ports; temp_port;
 		     prev_port = temp_port,
-			     temp_port = temp_port->next_port_in_aggregator) {
-			if (temp_port == port) { // the aggregator found - detach the port from this aggregator
+		     temp_port = temp_port->next_port_in_aggregator) {
+			if (temp_port == port) {
+				/* the aggregator found - detach the port from
+				 * this aggregator
+				 */
 				if (prev_port)
 					prev_port->next_port_in_aggregator = temp_port->next_port_in_aggregator;
 				else
@@ -2037,12 +2105,11 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				temp_aggregator->num_of_ports--;
 				if (temp_aggregator->num_of_ports == 0) {
 					select_new_active_agg = temp_aggregator->is_active;
-					// clear the aggregator
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
 						pr_info("%s: Removing an active aggregator\n",
 							slave->bond->dev->name);
-						// select new active aggregator
+						/* select new active aggregator */
 						ad_agg_selection_logic(__get_first_agg(port));
 					}
 				}
@@ -2083,7 +2150,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		goto re_arm;
 
 	/* check if agg_select_timer timer after initialize is timed out */
-	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
+	if (BOND_AD_INFO(bond).agg_select_timer &&
+	    !(--BOND_AD_INFO(bond).agg_select_timer)) {
 		slave = bond_first_slave_rcu(bond);
 		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
 
@@ -2145,7 +2213,8 @@ re_arm:
  * received frames (loopback). Since only the payload is given to this
  * function, it check for loopback.
  */
-static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length)
+static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
+				  u16 length)
 {
 	struct port *port;
 	int ret = RX_HANDLER_ANOTHER;
@@ -2173,7 +2242,9 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u1
 
 		case AD_TYPE_MARKER:
 			ret = RX_HANDLER_CONSUMED;
-			// No need to convert fields to Little Endian since we don't use the marker's fields.
+			/* No need to convert fields to Little Endian since we
+			 * don't use the marker's fields.
+			 */
 
 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
 			case AD_MARKER_INFORMATION_SUBTYPE:
@@ -2317,10 +2388,13 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	__release_state_machine_lock(port);
 }
 
-/*
- * set link state for bonding master: if we have an active
- * aggregator, we're up, if not, we're down.  Presumes that we cannot
- * have an active aggregator if there are no slaves with link up.
+/**
+ * bond_3ad_set_carrier - set link state for bonding master
+ * @bond - bonding structure
+ *
+ * if we have an active aggregator, we're up, if not, we're down.
+ * Presumes that we cannot have an active aggregator if there are
+ * no slaves with link up.
  *
  * This behavior complies with IEEE 802.3 section 43.3.9.
  *
@@ -2388,7 +2462,8 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 		ad_info->ports = aggregator->num_of_ports;
 		ad_info->actor_key = aggregator->actor_oper_aggregator_key;
 		ad_info->partner_key = aggregator->partner_oper_aggregator_key;
-		memcpy(ad_info->partner_system, aggregator->partner_system.mac_addr_value, ETH_ALEN);
+		memcpy(ad_info->partner_system,
+		       aggregator->partner_system.mac_addr_value, ETH_ALEN);
 		return 0;
 	}
 
@@ -2460,7 +2535,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* we couldn't find any suitable slave after the agg_no, so use the
-	 * first suitable found, if found. */
+	 * first suitable found, if found.
+	 */
 	if (first_ok_slave)
 		bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
 	else
@@ -2493,7 +2569,10 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 	return ret;
 }
 
-/*
+/**
+ * bond_3ad_update_lacp_rate - change the lacp rate
+ * @bond - bonding struct
+ *
  * When modify lacp_rate parameter via sysfs,
  * update actor_oper_port_state of each port.
  *
-- 
1.8.4
