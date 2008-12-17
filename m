From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 5/9] bonding: init port_params from template
Date: Wed, 17 Dec 2008 22:28:32 +0100
Message-ID: <20081217213012.598363663@jonathan.eitzenberger.org>
References: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:63182 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbYLQVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:18 -0500
Content-Disposition: inline; filename=bonding-3ad-init-port_info-from-template.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -1675,6 +1675,14 @@ static void ad_initialize_agg(struct agg
  */
 static void ad_initialize_port(struct port *port, int lacp_fast)
 {
+	static const struct port_params tmpl = {
+		.system_priority = 0xffff,
+		.key             = 1,
+		.port_number     = 1,
+		.port_priority   = 0xff,
+		.port_state      = 1,
+	};
+
 	if (port) {
 		port->actor_port_number = 1;
 		port->actor_port_priority = 0xff;
@@ -1691,18 +1699,9 @@ static void ad_initialize_port(struct po
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
 		}
 
-		port->partner_admin.system = null_mac_addr;
-		port->partner_oper.system  = null_mac_addr;
-		port->partner_admin.system_priority = 0xffff;
-		port->partner_oper.system_priority  = 0xffff;
-		port->partner_admin.key = 1;
-		port->partner_oper.key  = 1;
-		port->partner_admin.port_number = 1;
-		port->partner_oper.port_number  = 1;
-		port->partner_admin.port_priority = 0xff;
-		port->partner_oper.port_priority  = 0xff;
-		port->partner_admin.port_state = 1;
-		port->partner_oper.port_state  = 1;
+		memcpy(&port->partner_admin, &tmpl, sizeof(tmpl));
+		memcpy(&port->partner_oper, &tmpl, sizeof(tmpl));
+
 		port->is_enabled = 1;
 		// ****** private parameters ******
 		port->sm_vars = 0x3;

-- 
