From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 18/42] ns83820: fix net_device_ops support
Date: Tue, 06 Jan 2009 16:33:34 -0800
Message-ID: <20090107003347.314121969@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59026 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbZAGAxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:37 -0500
Content-Disposition: inline; filename=ns83820.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan_rx_register fuction is now in net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ns83820.c	2009-01-05 11:09:58.413568915 -0800
+++ b/drivers/net/ns83820.c	2009-01-05 11:10:50.579012963 -0800
@@ -1957,6 +1957,9 @@ static const struct net_device_ops netde
 	.ndo_set_multicast_list = ns83820_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= ns83820_tx_timeout,
+#ifdef NS83820_VLAN_ACCEL_SUPPORT
+	.ndo_vlan_rx_register	= ns83820_vlan_rx_register,
+#endif
 };
 
 static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
@@ -2216,7 +2219,6 @@ static int __devinit ns83820_init_one(st
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
 	/* We also support hardware vlan acceleration */
 	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	ndev->vlan_rx_register = ns83820_vlan_rx_register;
 #endif
 
 	if (using_dac) {

-- 

