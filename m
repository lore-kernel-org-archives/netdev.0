From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 3/9] bonding: use port_params in __record_pdu()
Date: Wed, 17 Dec 2008 22:28:30 +0100
Message-ID: <20081217213009.859308351@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:51798 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYLQVaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:16 -0500
Content-Disposition: inline; filename=bonding-3ad-__record_pdu-use-partner.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It helps in maintaining the various partner information values from
the LACPDU.  It also removes the pointless comment at the top.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -483,24 +483,25 @@ static u16 __ad_timer_to_ticks(u16 timer
  */
 static void __record_pdu(struct lacpdu *lacpdu, struct port *port)
 {
-	// validate lacpdu and port
 	if (lacpdu && port) {
+		struct port_params *partner = &port->partner_oper;
+
 		// record the new parameter values for the partner operational
-		port->partner_oper.port_number = ntohs(lacpdu->actor_port);
-		port->partner_oper.port_priority = ntohs(lacpdu->actor_port_priority);
-		port->partner_oper.system = lacpdu->actor_system;
-		port->partner_oper.system_priority = ntohs(lacpdu->actor_system_priority);
-		port->partner_oper.key = ntohs(lacpdu->actor_key);
-		port->partner_oper.port_state = lacpdu->actor_state;
+		partner->port_number = ntohs(lacpdu->actor_port);
+		partner->port_priority = ntohs(lacpdu->actor_port_priority);
+		partner->system = lacpdu->actor_system;
+		partner->system_priority = ntohs(lacpdu->actor_system_priority);
+		partner->key = ntohs(lacpdu->actor_key);
+		partner->port_state = lacpdu->actor_state;
 
 		// set actor_oper_port_state.defaulted to FALSE
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;
 
 		// set the partner sync. to on if the partner is sync. and the port is matched
 		if ((port->sm_vars & AD_PORT_MATCHED) && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
-			port->partner_oper.port_state |= AD_STATE_SYNCHRONIZATION;
+			partner->port_state |= AD_STATE_SYNCHRONIZATION;
 		} else {
-			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
+			partner->port_state &= ~AD_STATE_SYNCHRONIZATION;
 		}
 	}
 }

-- 
