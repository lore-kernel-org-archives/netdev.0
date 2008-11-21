From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/22] tehuti: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:50 -0800
Message-ID: <20081121232239.911615587@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57041 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938AbYKUXXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:24 -0500
Content-Disposition: inline; filename=tehuti.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tehuti.c	2008-11-21 14:10:27.000000000 -0800
+++ b/drivers/net/tehuti.c	2008-11-21 14:13:38.000000000 -0800
@@ -1885,6 +1885,21 @@ static void bdx_tx_push_desc_safe(struct
 	RET();
 }
 
+static const struct net_device_ops bdx_netdev_ops = {
+	.ndo_open	 	= bdx_open,
+	.ndo_stop		= bdx_close,
+	.ndo_start_xmit		= bdx_tx_transmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= bdx_ioctl,
+	.ndo_set_multicast_list = bdx_setmulti,
+	.ndo_get_stats		= bdx_get_stats,
+	.ndo_change_mtu		= bdx_change_mtu,
+	.ndo_set_mac_address	= bdx_set_mac,
+	.ndo_vlan_rx_register	= bdx_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= bdx_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= bdx_vlan_rx_kill_vid,
+};
+
 /**
  * bdx_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -1994,18 +2009,8 @@ bdx_probe(struct pci_dev *pdev, const st
 			goto err_out_iomap;
 		}
 
-		ndev->open = bdx_open;
-		ndev->stop = bdx_close;
-		ndev->hard_start_xmit = bdx_tx_transmit;
-		ndev->do_ioctl = bdx_ioctl;
-		ndev->set_multicast_list = bdx_setmulti;
-		ndev->get_stats = bdx_get_stats;
-		ndev->change_mtu = bdx_change_mtu;
-		ndev->set_mac_address = bdx_set_mac;
+		ndev->netdev_ops = &bdx_netdev_ops;
 		ndev->tx_queue_len = BDX_NDEV_TXQ_LEN;
-		ndev->vlan_rx_register = bdx_vlan_rx_register;
-		ndev->vlan_rx_add_vid = bdx_vlan_rx_add_vid;
-		ndev->vlan_rx_kill_vid = bdx_vlan_rx_kill_vid;
 
 		bdx_ethtool_ops(ndev);	/* ethtool interface */
 

-- 

