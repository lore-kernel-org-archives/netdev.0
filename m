From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 8/9] bonding: use port_params in __update_default_selected()
Date: Wed, 17 Dec 2008 22:28:35 +0100
Message-ID: <20081217213016.567386555@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56828 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbYLQVaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:21 -0500
Content-Disposition: inline; filename=bonding-3ad-__update-default-selected-use-port_params.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also removed some of the unneeded braces in the if condition to
improve readability and a little bit of reformatting.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -543,16 +543,18 @@ static void __update_selected(struct lac
  */
 static void __update_default_selected(struct port *port)
 {
-	// validate the port
 	if (port) {
+		const struct port_params *admin = &port->partner_admin;
+		const struct port_params *oper = &port->partner_oper;
+
 		// check if any parameter is different
-		if ((port->partner_admin.port_number != port->partner_oper.port_number) ||
-		    (port->partner_admin.port_priority != port->partner_oper.port_priority) ||
-		    MAC_ADDRESS_COMPARE(&(port->partner_admin.system), &(port->partner_oper.system)) ||
-		    (port->partner_admin.system_priority != port->partner_oper.system_priority) ||
-		    (port->partner_admin.key != port->partner_oper.key) ||
-		    ((port->partner_admin.port_state & AD_STATE_AGGREGATION) != (port->partner_oper.port_state & AD_STATE_AGGREGATION))
-		   ) {
+		if (admin->port_number != oper->port_number
+		    || admin->port_priority != oper->port_priority
+		    || MAC_ADDRESS_COMPARE(&admin->system, &oper->system)
+		    || admin->system_priority != oper->system_priority
+		    || admin->key != oper->key
+		    || (admin->port_state & AD_STATE_AGGREGATION)
+			!= (oper->port_state & AD_STATE_AGGREGATION)) {
 			// update the state machine Selected variable
 			port->sm_vars &= ~AD_PORT_SELECTED;
 		}

-- 
