From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 1/9] bonding: improve elaborate port_state assignment
Date: Wed, 17 Dec 2008 22:28:28 +0100
Message-ID: <20081217213007.374131068@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:57389 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYLQVaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:14 -0500
Content-Disposition: inline; filename=bonding-3ad-improve-partner-assignment.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous code was just a funny way of assigning both values (they
are both of type u8).

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -491,16 +491,7 @@ static void __record_pdu(struct lacpdu *
 		port->partner_oper_system = lacpdu->actor_system;
 		port->partner_oper_system_priority = ntohs(lacpdu->actor_system_priority);
 		port->partner_oper_key = ntohs(lacpdu->actor_key);
-		// zero partener's lase states
-		port->partner_oper_port_state = 0;
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_LACP_ACTIVITY);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_LACP_TIMEOUT);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_AGGREGATION);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_COLLECTING);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_DISTRIBUTING);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_DEFAULTED);
-		port->partner_oper_port_state |= (lacpdu->actor_state & AD_STATE_EXPIRED);
+		port->partner_oper_port_state = lacpdu->actor_state;
 
 		// set actor_oper_port_state.defaulted to FALSE
 		port->actor_oper_port_state &= ~AD_STATE_DEFAULTED;

-- 
