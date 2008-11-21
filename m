From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/22] myri10ge: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:44 -0800
Message-ID: <20081121232239.404760373@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57018 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582AbYKUXXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:18 -0500
Content-Disposition: inline; filename=myri10ge.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/myri10ge/myri10ge.c	2008-11-20 22:27:33.000000000 -0800
+++ b/drivers/net/myri10ge/myri10ge.c	2008-11-20 22:34:24.000000000 -0800
@@ -3731,6 +3731,17 @@ abort_with_fw:
 	myri10ge_load_firmware(mgp, 0);
 }
 
+static const struct net_device_ops myri10ge_netdev_ops = {
+	.ndo_open		= myri10ge_open,
+	.ndo_stop		= myri10ge_close,
+	.ndo_start_xmit		= myri10ge_xmit,
+	.ndo_get_stats		= myri10ge_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= myri10ge_change_mtu,
+	.ndo_set_multicast_list = myri10ge_set_multicast_list,
+	.ndo_set_mac_address	= myri10ge_set_mac_address,
+};
+
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
@@ -3862,15 +3873,10 @@ static int myri10ge_probe(struct pci_dev
 		myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
 	if ((myri10ge_initial_mtu + ETH_HLEN) < 68)
 		myri10ge_initial_mtu = 68;
+
+	netdev->netdev_ops = &myri10ge_netdev_ops;
 	netdev->mtu = myri10ge_initial_mtu;
-	netdev->open = myri10ge_open;
-	netdev->stop = myri10ge_close;
-	netdev->hard_start_xmit = myri10ge_xmit;
-	netdev->get_stats = myri10ge_get_stats;
 	netdev->base_addr = mgp->iomem_base;
-	netdev->change_mtu = myri10ge_change_mtu;
-	netdev->set_multicast_list = myri10ge_set_multicast_list;
-	netdev->set_mac_address = myri10ge_set_mac_address;
 	netdev->features = mgp->features;
 
 	if (dac_enabled)

-- 

