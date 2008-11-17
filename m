From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 24/33] via-velocity: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:31 -0800
Message-ID: <20081117234356.835021131@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55102 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbYKRAAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:16 -0500
Content-Disposition: inline; filename=via-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/via-velocity.c	2008-11-17 12:56:02.000000000 -0800
+++ b/drivers/net/via-velocity.c	2008-11-17 12:58:13.000000000 -0800
@@ -849,6 +849,19 @@ static int velocity_soft_reset(struct ve
 	return 0;
 }
 
+static const struct net_device_ops velocity_netdev_ops = {
+	.open = velocity_open,
+	.stop = velocity_close,
+	.get_stats = velocity_get_stats,
+	.validate_addr	= eth_validate_addr,
+	.set_multicast_list = velocity_set_multi,
+	.change_mtu = velocity_change_mtu,
+	.do_ioctl = velocity_ioctl,
+	.vlan_rx_add_vid = velocity_vlan_rx_add_vid,
+	.vlan_rx_kill_vid = velocity_vlan_rx_kill_vid,
+	.vlan_rx_register = velocity_vlan_rx_register,
+};
+
 /**
  *	velocity_found1		-	set up discovered velocity card
  *	@pdev: PCI device
@@ -958,18 +971,9 @@ static int __devinit velocity_found1(str
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
 	dev->irq = pdev->irq;
-	dev->open = velocity_open;
 	dev->hard_start_xmit = velocity_xmit;
-	dev->stop = velocity_close;
-	dev->get_stats = velocity_get_stats;
-	dev->set_multicast_list = velocity_set_multi;
-	dev->do_ioctl = velocity_ioctl;
+	dev->netdev_ops = &velocity_netdev_ops;
 	dev->ethtool_ops = &velocity_ethtool_ops;
-	dev->change_mtu = velocity_change_mtu;
-
-	dev->vlan_rx_add_vid = velocity_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = velocity_vlan_rx_kill_vid;
-	dev->vlan_rx_register = velocity_vlan_rx_register;
 
 #ifdef  VELOCITY_ZERO_COPY_SUPPORT
 	dev->features |= NETIF_F_SG;

-- 

