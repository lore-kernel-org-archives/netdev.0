From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/42] pcnet32: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:28 -0800
Message-ID: <20090107003346.746759865@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59016 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756058AbZAGAxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:31 -0500
Content-Disposition: inline; filename=pcnet32.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcnet32.c	2009-01-05 22:35:10.546318919 -0800
+++ b/drivers/net/pcnet32.c	2009-01-05 22:45:01.278569923 -0800
@@ -1568,6 +1568,22 @@ pcnet32_probe_pci(struct pci_dev *pdev, 
 	return err;
 }
 
+static const struct net_device_ops pcnet32_netdev_ops = {
+	.ndo_open		= pcnet32_open,
+	.ndo_stop 		= pcnet32_close,
+	.ndo_start_xmit		= pcnet32_start_xmit,
+	.ndo_tx_timeout		= pcnet32_tx_timeout,
+	.ndo_get_stats		= pcnet32_get_stats,
+	.ndo_set_multicast_list = pcnet32_set_multicast_list,
+	.ndo_do_ioctl		= pcnet32_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= pcnet32_poll_controller,
+#endif
+};
+
 /* pcnet32_probe1
  *  Called from both pcnet32_probe_vlbus and pcnet_probe_pci.
  *  pdev will be NULL when called from pcnet32_probe_vlbus.
@@ -1934,20 +1950,10 @@ pcnet32_probe1(unsigned long ioaddr, int
 	lp->watchdog_timer.function = (void *)&pcnet32_watchdog;
 
 	/* The PCNET32-specific entries in the device structure. */
-	dev->open = &pcnet32_open;
-	dev->hard_start_xmit = &pcnet32_start_xmit;
-	dev->stop = &pcnet32_close;
-	dev->get_stats = &pcnet32_get_stats;
-	dev->set_multicast_list = &pcnet32_set_multicast_list;
-	dev->do_ioctl = &pcnet32_ioctl;
+	dev->netdev_ops = &pcnet32_netdev_ops;
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
-	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = pcnet32_poll_controller;
-#endif
-
 	/* Fill in the generic fields of the device structure. */
 	if (register_netdev(dev))
 		goto err_free_ring;

-- 

