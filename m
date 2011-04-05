From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 6/14] ehea: Add vlan_features
Date: Tue, 5 Apr 2011 21:35:04 +1000
Message-ID: <20110405213504.52422755@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44250 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1DELfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:35:07 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We weren't enabling any VLAN features so we missed out on checksum
offload and TSO when using VLANs. Enable them.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-04-05 20:36:33.847294106 +1000
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-04-05 20:36:34.437226735 +1000
@@ -3224,6 +3224,8 @@ struct ehea_port *ehea_setup_single_port
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |
+			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)
