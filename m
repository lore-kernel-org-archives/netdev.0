From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 13/45] com20020: convert to net_devic_ops
Date: Fri, 09 Jan 2009 15:01:10 -0800
Message-ID: <20090109230137.677751083@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42179 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbZAIXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:55 -0500
Content-Disposition: inline; filename=com2020-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/arcnet/com20020-isa.c |    2 ++
 drivers/net/arcnet/com20020-pci.c |    3 +++
 drivers/net/arcnet/com20020.c     |   10 ++++++++--
 include/linux/com20020.h          |    1 +
 4 files changed, 14 insertions(+), 2 deletions(-)

--- a/drivers/net/arcnet/com20020-isa.c	2009-01-09 09:55:56.000000000 -0800
+++ b/drivers/net/arcnet/com20020-isa.c	2009-01-09 09:56:23.000000000 -0800
@@ -151,6 +151,8 @@ static int __init com20020_init(void)
 	if (node && node != 0xff)
 		dev->dev_addr[0] = node;
 
+	dev->netdev_ops = &com20020_netdev_ops;
+
 	lp = netdev_priv(dev);
 	lp->backplane = backplane;
 	lp->clockp = clockp & 7;
--- a/drivers/net/arcnet/com20020-pci.c	2009-01-09 09:55:56.000000000 -0800
+++ b/drivers/net/arcnet/com20020-pci.c	2009-01-09 09:56:23.000000000 -0800
@@ -72,6 +72,9 @@ static int __devinit com20020pci_probe(s
 	dev = alloc_arcdev(device);
 	if (!dev)
 		return -ENOMEM;
+
+	dev->netdev_ops = &com20020_netdev_ops;
+
 	lp = netdev_priv(dev);
 
 	pci_set_drvdata(pdev, dev);
--- a/drivers/net/arcnet/com20020.c	2009-01-09 09:55:56.000000000 -0800
+++ b/drivers/net/arcnet/com20020.c	2009-01-09 09:56:23.000000000 -0800
@@ -149,6 +149,14 @@ int com20020_check(struct net_device *de
 	return 0;
 }
 
+const struct net_device_ops com20020_netdev_ops = {
+	.ndo_open	= arcnet_open,
+	.ndo_stop	= arcnet_close,
+	.ndo_start_xmit = arcnet_send_packet,
+	.ndo_tx_timeout = arcnet_timeout,
+	.ndo_set_multicast_list = com20020_set_mc_list,
+};
+
 /* Set up the struct net_device associated with this card.  Called after
  * probing succeeds.
  */
@@ -170,8 +178,6 @@ int com20020_found(struct net_device *de
 	lp->hw.copy_from_card = com20020_copy_from_card;
 	lp->hw.close = com20020_close;
 
-	dev->set_multicast_list = com20020_set_mc_list;
-
 	if (!dev->dev_addr[0])
 		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN*8);	/* FIXME: do this some other way! */
 
--- a/include/linux/com20020.h	2009-01-09 09:55:56.000000000 -0800
+++ b/include/linux/com20020.h	2009-01-09 09:56:23.000000000 -0800
@@ -29,6 +29,7 @@
 
 int com20020_check(struct net_device *dev);
 int com20020_found(struct net_device *dev, int shared);
+const struct net_device_ops com20020_netdev_ops;
 
 /* The number of low I/O ports used by the card. */
 #define ARCNET_TOTAL_SIZE 8


