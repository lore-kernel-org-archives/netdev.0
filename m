From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 03/10] 802.3ad: turn ports is_individual into a bool
Date: Tue, 23 Dec 2008 23:01:04 +0100
Message-ID: <20081223220553.680185723@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Holger Eitzenberger <heitzenberger@astaro.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:64006 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbYLWWGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:00 -0500
Content-Disposition: inline; filename=bonding-3ad-is_individual-bool.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn ports is_individual into a bool.  There is no functional change.

Signed-off-by: Holger Eitzenberger <heitzenberger@astaro.com>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -1359,9 +1359,9 @@ static void ad_port_selection_logic(stru
 			// update the new aggregator's parameters
 			// if port was responsed from the end-user
 			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS) {// if port is full duplex
-				port->aggregator->is_individual = 0;
+				port->aggregator->is_individual = false;
 			} else {
-				port->aggregator->is_individual = 1;
+				port->aggregator->is_individual = true;
 			}
 
 			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
@@ -1613,7 +1613,7 @@ static void ad_agg_selection_logic(struc
 static void ad_clear_agg(struct aggregator *aggregator)
 {
 	if (aggregator) {
-		aggregator->is_individual = 0;
+		aggregator->is_individual = false;
 		aggregator->actor_admin_aggregator_key = 0;
 		aggregator->actor_oper_aggregator_key = 0;
 		aggregator->partner_system = null_mac_addr;
Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -184,7 +184,7 @@ struct port;
 typedef struct aggregator {
 	struct mac_addr aggregator_mac_address;
 	u16 aggregator_identifier;
-	u16 is_individual;		 // BOOLEAN
+	bool is_individual;
 	u16 actor_admin_aggregator_key;
 	u16 actor_oper_aggregator_key;
 	struct mac_addr partner_system;

-- 
