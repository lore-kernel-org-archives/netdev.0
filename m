From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 17/22] bnx2x: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:55 -0800
Message-ID: <20081121232240.333740078@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57061 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYKUXXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:34 -0500
Content-Disposition: inline; filename=bnx2x.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bnx2x_main.c	2008-11-21 14:31:35.000000000 -0800
+++ b/drivers/net/bnx2x_main.c	2008-11-21 14:34:01.000000000 -0800
@@ -10002,6 +10002,25 @@ static void poll_bnx2x(struct net_device
 }
 #endif
 
+static const struct net_device_ops bnx2x_netdev_ops = {
+	.ndo_open		= bnx2x_open,
+	.ndo_stop		= bnx2x_close,
+	.ndo_start_xmit		= bnx2x_start_xmit,
+	.ndo_set_multicast_list = bnx2x_set_rx_mode,
+	.ndo_set_mac_address	= bnx2x_change_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= bnx2x_ioctl,
+	.ndo_change_mtu		= bnx2x_change_mtu,
+	.ndo_tx_timeout		= bnx2x_tx_timeout,
+#ifdef BCM_VLAN
+	.ndo_vlan_rx_register	= bnx2x_vlan_rx_register,
+#endif
+#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+	.ndo_poll_controller	= poll_bnx2x,
+#endif
+};
+
+
 static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 				    struct net_device *dev)
 {
@@ -10112,23 +10131,10 @@ static int __devinit bnx2x_init_dev(stru
 	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0 + BP_PORT(bp)*16, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0 + BP_PORT(bp)*16, 0);
 
-	dev->hard_start_xmit = bnx2x_start_xmit;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
+	dev->netdev_ops = &bnx2x_netdev_ops;
 	dev->ethtool_ops = &bnx2x_ethtool_ops;
-	dev->open = bnx2x_open;
-	dev->stop = bnx2x_close;
-	dev->set_multicast_list = bnx2x_set_rx_mode;
-	dev->set_mac_address = bnx2x_change_mac_addr;
-	dev->do_ioctl = bnx2x_ioctl;
-	dev->change_mtu = bnx2x_change_mtu;
-	dev->tx_timeout = bnx2x_tx_timeout;
-#ifdef BCM_VLAN
-	dev->vlan_rx_register = bnx2x_vlan_rx_register;
-#endif
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
-	dev->poll_controller = poll_bnx2x;
-#endif
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_HW_CSUM;
 	if (bp->flags & USING_DAC_FLAG)

-- 

