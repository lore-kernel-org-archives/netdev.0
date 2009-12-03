From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] virtio_net: add more ethtool information
Date: Wed, 02 Dec 2009 22:32:26 -0800
Message-ID: <20091203063311.902077645@vyatta.com>
References: <20091203063225.926337440@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59372 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbZLCH3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 02:29:03 -0500
Content-Disposition: inline; filename=vda-speed.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful for some tools (as well as bonding, and bridging)
for virtio network interface provide more ethtool information.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/virtio_net.c	2009-12-01 14:24:14.766450584 -0800
+++ b/drivers/net/virtio_net.c	2009-12-01 16:49:18.295535415 -0800
@@ -763,7 +763,36 @@ static void virtnet_vlan_rx_kill_vid(str
 		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
 }
 
+static void virtnet_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *info)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	strcpy(info->driver, "virtnet");
+	strcpy(info->version, "0.1");
+	strcpy(info->fw_version, "N/A");
+	strcpy(info->bus_info, dev_driver_string(&vi->vdev->dev));
+}
+
+static int virtnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = SUPPORTED_1000baseT_Full |
+		SUPPORTED_Autoneg | SUPPORTED_FIBRE;
+	cmd->advertising = ADVERTISED_1000baseT_Full |
+		ADVERTISED_Autoneg | ADVERTISED_FIBRE;
+	cmd->speed = SPEED_1000;
+	cmd->duplex = DUPLEX_FULL;
+	cmd->port = PORT_FIBRE;
+	cmd->phy_address = 0;
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->autoneg = AUTONEG_ENABLE;
+
+	return 0;
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_settings = virtnet_get_settings,
+	.get_drvinfo = virtnet_get_drvinfo,
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,

-- 

