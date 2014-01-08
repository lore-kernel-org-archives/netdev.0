From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 3/3] bonding: remove dead code from 3ad
Date: Wed,  8 Jan 2014 16:46:48 +0100
Message-ID: <1389196008-28578-4-git-send-email-vfalico@redhat.com>
References: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755850AbaAHPvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 10:51:08 -0500
In-Reply-To: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That code has been around for ages without being used.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 78 ------------------------------------------
 1 file changed, 78 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7118eef..29db1ca 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -594,40 +594,6 @@ static void __update_ntt(struct lacpdu *lacpdu, struct port *port)
 }
 
 /**
- * __attach_bond_to_agg
- * @port: the port we're looking at
- *
- * Handle the attaching of the port's control parser/multiplexer and the
- * aggregator. This function does nothing since the parser/multiplexer of the
- * receive and the parser/multiplexer of the aggregator are already combined.
- */
-static void __attach_bond_to_agg(struct port *port)
-{
-	port = NULL; /* just to satisfy the compiler */
-	/* This function does nothing since the parser/multiplexer of the
-	 * receive and the parser/multiplexer of the aggregator are already
-	 * combined.
-	 */
-}
-
-/**
- * __detach_bond_from_agg
- * @port: the port we're looking at
- *
- * Handle the detaching of the port's control parser/multiplexer from the
- * aggregator. This function does nothing since the parser/multiplexer of the
- * receive and the parser/multiplexer of the aggregator are already combined.
- */
-static void __detach_bond_from_agg(struct port *port)
-{
-	port = NULL; /* just to satisfy the compiler */
-	/* This function does nothing since the parser/multiplexer of the
-	 * receive and the parser/multiplexer of the aggregator are already
-	 * combined
-	 */
-}
-
-/**
  * __agg_ports_are_ready - check if all ports in an aggregator are ready
  * @aggregator: the aggregator we're looking at
  *
@@ -964,7 +930,6 @@ static void ad_mux_machine(struct port *port)
 			 port->sm_mux_state);
 		switch (port->sm_mux_state) {
 		case AD_MUX_DETACHED:
-			__detach_bond_from_agg(port);
 			port->actor_oper_port_state &= ~AD_STATE_SYNCHRONIZATION;
 			ad_disable_collecting_distributing(port);
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
@@ -975,7 +940,6 @@ static void ad_mux_machine(struct port *port)
 			port->sm_mux_timer_counter = __ad_timer_to_ticks(AD_WAIT_WHILE_TIMER, 0);
 			break;
 		case AD_MUX_ATTACHED:
-			__attach_bond_to_agg(port);
 			port->actor_oper_port_state |= AD_STATE_SYNCHRONIZATION;
 			port->actor_oper_port_state &= ~AD_STATE_COLLECTING;
 			port->actor_oper_port_state &= ~AD_STATE_DISTRIBUTING;
@@ -1774,48 +1738,6 @@ static void ad_disable_collecting_distributing(struct port *port)
 	}
 }
 
-#if 0
-/**
- * ad_marker_info_send - send a marker information frame
- * @port: the port we're looking at
- *
- * This function does nothing since we decided not to implement send and handle
- * response for marker PDU's, in this stage, but only to respond to marker
- * information.
- */
-static void ad_marker_info_send(struct port *port)
-{
-	struct bond_marker marker;
-	u16 index;
-
-	// fill the marker PDU with the appropriate values
-	marker.subtype = 0x02;
-	marker.version_number = 0x01;
-	marker.tlv_type = AD_MARKER_INFORMATION_SUBTYPE;
-	marker.marker_length = 0x16;
-	// convert requester_port to Big Endian
-	marker.requester_port = (((port->actor_port_number & 0xFF) << 8) |((u16)(port->actor_port_number & 0xFF00) >> 8));
-	marker.requester_system = port->actor_system;
-	// convert requester_port(u32) to Big Endian
-	marker.requester_transaction_id =
-		(((++port->transaction_id & 0xFF) << 24)
-		 | ((port->transaction_id & 0xFF00) << 8)
-		 | ((port->transaction_id & 0xFF0000) >> 8)
-		 | ((port->transaction_id & 0xFF000000) >> 24));
-	marker.pad = 0;
-	marker.tlv_type_terminator = 0x00;
-	marker.terminator_length = 0x00;
-	for (index = 0; index < 90; index++)
-		marker.reserved_90[index] = 0;
-
-	// send the marker information
-	if (ad_marker_send(port, &marker) >= 0) {
-		pr_debug("Sent Marker Information on port %d\n",
-			 port->actor_port_number);
-	}
-}
-#endif
-
 /**
  * ad_marker_info_received - handle receive of a Marker information frame
  * @marker_info: Marker info received
-- 
1.8.4
