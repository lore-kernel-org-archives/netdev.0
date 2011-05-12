From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 06/15] ehea: Add vlan_features
Date: Thu, 12 May 2011 10:52:19 +1000
Message-ID: <20110512005623.019634729@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41004 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752956Ab1ELBm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:42:58 -0400
Content-Disposition: inline; filename=ehea_7.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We weren't enabling any VLAN features so we missed out on checksum
offload and TSO when using VLANs. Enable them.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:54.730197374 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:55.870215448 +1000
@@ -3223,6 +3223,8 @@ struct ehea_port *ehea_setup_single_port
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_RXCSUM;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |
+			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)


