From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 4/9] bonding: use plain memcpy in __record_default()
Date: Wed, 17 Dec 2008 22:28:31 +0100
Message-ID: <20081217213011.268895930@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63920 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYLQVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:18 -0500
Content-Disposition: inline; filename=bonding-3ad-__record_default-use-partner.dif
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove the pointless comment at the top.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -516,15 +516,10 @@ static void __record_pdu(struct lacpdu *
  */
 static void __record_default(struct port *port)
 {
-	// validate the port
 	if (port) {
 		// record the partner admin parameters
-		port->partner_oper.port_number = port->partner_admin.port_number;
-		port->partner_oper.port_priority = port->partner_admin.port_priority;
-		port->partner_oper.system = port->partner_admin.system;
-		port->partner_oper.system_priority = port->partner_admin.system_priority;
-		port->partner_oper.key = port->partner_admin.key;
-		port->partner_oper.port_state = port->partner_admin.port_state;
+		memcpy(&port->partner_oper, &port->partner_admin,
+		       sizeof(struct port_params));
 
 		// set actor_oper_port_state.defaulted to true
 		port->actor_oper_port_state |= AD_STATE_DEFAULTED;

-- 
