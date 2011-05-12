From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 12/15] ehea: Add 64bit statistics
Date: Thu, 12 May 2011 10:52:25 +1000
Message-ID: <20110512005623.591460412@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46578 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab1ELB2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:28:00 -0400
Content-Disposition: inline; filename=ehea_17.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to using ndo_get_stats64 to get 64bit statistics.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:00.220284417 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:02.700323737 +1000
@@ -321,10 +321,10 @@ out:
 	spin_unlock_irqrestore(&ehea_bcmc_regs.lock, flags);
 }
 
-static struct net_device_stats *ehea_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
+					struct rtnl_link_stats64 *stats)
 {
 	struct ehea_port *port = netdev_priv(dev);
-	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
 	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
 	int i;
@@ -3034,7 +3034,7 @@ static const struct net_device_ops ehea_
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ehea_netpoll,
 #endif
-	.ndo_get_stats		= ehea_get_stats,
+	.ndo_get_stats64	= ehea_get_stats64,
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= ehea_set_multicast_list,


