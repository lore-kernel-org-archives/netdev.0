From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/42] ipg: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:22 -0800
Message-ID: <20090107003346.112191664@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58990 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755424AbZAGAxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:12 -0500
Content-Disposition: inline; filename=ipg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ipg.c	2009-01-05 16:45:32.729571177 -0800
+++ b/drivers/net/ipg.c	2009-01-05 16:48:07.518569219 -0800
@@ -2210,6 +2210,19 @@ static void __devexit ipg_remove(struct 
 	pci_set_drvdata(pdev, NULL);
 }
 
+static const struct net_device_ops ipg_netdev_ops = {
+	.ndo_open		= ipg_nic_open,
+	.ndo_stop		= ipg_nic_stop,
+	.ndo_start_xmit		= ipg_nic_hard_start_xmit,
+	.ndo_get_stats		= ipg_nic_get_stats,
+	.ndo_set_multicast_list = ipg_nic_set_multicast_list,
+	.ndo_do_ioctl		= ipg_ioctl,
+	.ndo_tx_timeout 	= ipg_tx_timeout,
+	.ndo_change_mtu 	= ipg_nic_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit ipg_probe(struct pci_dev *pdev,
 			       const struct pci_device_id *id)
 {
@@ -2258,15 +2271,7 @@ static int __devinit ipg_probe(struct pc
 
 	/* Declare IPG NIC functions for Ethernet device methods.
 	 */
-	dev->open = &ipg_nic_open;
-	dev->stop = &ipg_nic_stop;
-	dev->hard_start_xmit = &ipg_nic_hard_start_xmit;
-	dev->get_stats = &ipg_nic_get_stats;
-	dev->set_multicast_list = &ipg_nic_set_multicast_list;
-	dev->do_ioctl = ipg_ioctl;
-	dev->tx_timeout = ipg_tx_timeout;
-	dev->change_mtu = &ipg_nic_change_mtu;
-
+	dev->netdev_ops = &ipg_netdev_ops;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	SET_ETHTOOL_OPS(dev, &ipg_ethtool_ops);
 

-- 

