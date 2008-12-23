From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 02/10] 802.3ad: turn ports is_enabled into a bool
Date: Tue, 23 Dec 2008 23:01:03 +0100
Message-ID: <20081223220552.421348746@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54589 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbYLWWF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:05:59 -0500
Content-Disposition: inline; filename=bonding-3ad-is_enabled-bool.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn ports is_enabled into a bool.  There is no functional change.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -224,7 +224,8 @@ typedef struct port {
 	struct port_params partner_admin;
 	struct port_params partner_oper;
 
-	u16 is_enabled;	      // BOOLEAN
+	bool is_enabled;
+
 	// ****** PRIVATE PARAMETERS ******
 	u16 sm_vars;	      // all state machines variables for this port
 	rx_states_t sm_rx_state;	// state machine rx state
Index: bonding-2.6/drivers/net/bonding/bond_3ad.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.c
+++ bonding-2.6/drivers/net/bonding/bond_3ad.c
@@ -1679,7 +1679,7 @@ static void ad_initialize_port(struct po
 		memcpy(&port->partner_admin, &tmpl, sizeof(tmpl));
 		memcpy(&port->partner_oper, &tmpl, sizeof(tmpl));
 
-		port->is_enabled = 1;
+		port->is_enabled = true;
 		// ****** private parameters ******
 		port->sm_vars = 0x3;
 		port->sm_rx_state = 0;
@@ -2308,14 +2308,14 @@ void bond_3ad_handle_link_change(struct 
 	// on link down we are zeroing duplex and speed since some of the adaptors(ce1000.lan) report full duplex/speed instead of N/A(duplex) / 0(speed)
 	// on link up we are forcing recheck on the duplex and speed since some of he adaptors(ce1000.lan) report
 	if (link == BOND_LINK_UP) {
-		port->is_enabled = 1;
+		port->is_enabled = true;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 		port->actor_oper_port_key=port->actor_admin_port_key |= __get_duplex(port);
 		port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 		port->actor_oper_port_key=port->actor_admin_port_key |= (__get_link_speed(port) << 1);
 	} else {
 		/* link has failed */
-		port->is_enabled = 0;
+		port->is_enabled = false;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
 		port->actor_oper_port_key= (port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS);
 	}

-- 
