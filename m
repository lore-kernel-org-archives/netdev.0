From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 9/9] bonding: use port_params in __update_lacpdu_from_port
Date: Wed, 17 Dec 2008 22:28:36 +0100
Message-ID: <20081217213017.927925290@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:54210 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbYLQVaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:21 -0500
Content-Disposition: inline; filename=bonding-3ad-__update_lacpdu_from_port-use-port_params.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -769,6 +769,7 @@ static struct aggregator *__get_active_a
 static inline void __update_lacpdu_from_port(struct port *port)
 {
 	struct lacpdu *lacpdu = &port->lacpdu;
+	const struct port_params *partner = &port->partner_oper;
 
 	/* update current actual Actor parameters */
 	/* lacpdu->subtype                   initialized
@@ -789,12 +790,12 @@ static inline void __update_lacpdu_from_
 	 * lacpdu->partner_information_length initialized
 	 */
 
-	lacpdu->partner_system_priority = htons(port->partner_oper.system_priority);
-	lacpdu->partner_system = port->partner_oper.system;
-	lacpdu->partner_key = htons(port->partner_oper.key);
-	lacpdu->partner_port_priority = htons(port->partner_oper.port_priority);
-	lacpdu->partner_port = htons(port->partner_oper.port_number);
-	lacpdu->partner_state = port->partner_oper.port_state;
+	lacpdu->partner_system_priority = htons(partner->system_priority);
+	lacpdu->partner_system = partner->system;
+	lacpdu->partner_key = htons(partner->key);
+	lacpdu->partner_port_priority = htons(partner->port_priority);
+	lacpdu->partner_port = htons(partner->port_number);
+	lacpdu->partner_state = partner->port_state;
 
 	/* lacpdu->reserved_3_2              initialized
 	 * lacpdu->tlv_type_collector_info   initialized

-- 
