From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 10/11] ioc3-eth: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:44:55 +0400
Message-ID: <20090411174455.GJ16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:20893 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758332AbZDKRpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:45:02 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1586973ywb.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:45:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/ioc3-eth.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index cbc63ff..c5593f4 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1214,6 +1214,19 @@ static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 }
 #endif
 
+static const struct net_device_ops ioc3_netdev_ops = {
+	.ndo_open		= ioc3_open,
+	.ndo_stop		= ioc3_close,
+	.ndo_start_xmit		= ioc3_start_xmit,
+	.ndo_tx_timeout		= ioc3_timeout,
+	.ndo_get_stats		= ioc3_get_stats,
+	.ndo_set_multicast_list	= ioc3_set_multicast_list,
+	.ndo_do_ioctl		= ioc3_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= ioc3_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static int __devinit ioc3_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
@@ -1310,15 +1323,8 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 	ioc3_get_eaddr(ip);
 
 	/* The IOC3-specific entries in the device structure. */
-	dev->open		= ioc3_open;
-	dev->hard_start_xmit	= ioc3_start_xmit;
-	dev->tx_timeout		= ioc3_timeout;
 	dev->watchdog_timeo	= 5 * HZ;
-	dev->stop		= ioc3_close;
-	dev->get_stats		= ioc3_get_stats;
-	dev->do_ioctl		= ioc3_ioctl;
-	dev->set_multicast_list	= ioc3_set_multicast_list;
-	dev->set_mac_address	= ioc3_set_mac_address;
+	dev->netdev_ops		= &ioc3_netdev_ops;
 	dev->ethtool_ops	= &ioc3_ethtool_ops;
 	dev->features		= NETIF_F_IP_CSUM;
 
