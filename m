From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 7/9] bonding: use port_params in __update_selected()
Date: Wed, 17 Dec 2008 22:28:34 +0100
Message-ID: <20081217213015.269486347@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:59374 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbYLQVaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:19 -0500
Content-Disposition: inline; filename=bonding-3ad-__update-selected-use-port_params.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -513,16 +513,16 @@ static void __record_default(struct port
  */
 static void __update_selected(struct lacpdu *lacpdu, struct port *port)
 {
-	// validate lacpdu and port
 	if (lacpdu && port) {
+		const struct port_params *partner = &port->partner_oper;
+
 		// check if any parameter is different
-		if ((ntohs(lacpdu->actor_port) != port->partner_oper.port_number) ||
-		    (ntohs(lacpdu->actor_port_priority) != port->partner_oper.port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->partner_oper.system)) ||
-		    (ntohs(lacpdu->actor_system_priority) != port->partner_oper.system_priority) ||
-		    (ntohs(lacpdu->actor_key) != port->partner_oper.key) ||
-		    ((lacpdu->actor_state & AD_STATE_AGGREGATION) != (port->partner_oper.port_state & AD_STATE_AGGREGATION))
-		   ) {
+		if (ntohs(lacpdu->actor_port) != partner->port_number
+		    || ntohs(lacpdu->actor_port_priority) != partner->port_priority
+		    || MAC_ADDRESS_COMPARE(&lacpdu->actor_system, &partner->system)
+		    || ntohs(lacpdu->actor_system_priority) != partner->system_priority
+		    || ntohs(lacpdu->actor_key) != partner->key
+		    || (lacpdu->actor_state & AD_STATE_AGGREGATION) != (partner->port_state & AD_STATE_AGGREGATION)) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}

-- 
