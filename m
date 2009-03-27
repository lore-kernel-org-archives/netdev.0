From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 08/30] IRDA: convert donauboe to net_device_ops
Date: Thu, 26 Mar 2009 18:11:22 -0700
Message-ID: <20090327011255.530270675@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43172 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522AbZC0BZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:25:40 -0400
Content-Disposition: inline; filename=donauboe.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/irda/donauboe.c	2009-03-21 12:36:57.000000000 -0700
+++ b/drivers/net/irda/donauboe.c	2009-03-22 23:22:08.669527272 -0700
@@ -1524,6 +1524,13 @@ toshoboe_close (struct pci_dev *pci_dev)
   free_netdev(self->netdev);
 }
 
+static const struct net_device_ops toshoboe_netdev_ops = {
+	.ndo_open	= toshoboe_net_open,
+	.ndo_stop	= toshoboe_net_close,
+	.ndo_start_xmit	= toshoboe_hard_xmit,
+	.ndo_do_ioctl	= toshoboe_net_ioctl,
+};
+
 static int
 toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
 {
@@ -1657,10 +1664,7 @@ toshoboe_open (struct pci_dev *pci_dev, 
 #endif
 
   SET_NETDEV_DEV(dev, &pci_dev->dev);
-  dev->hard_start_xmit = toshoboe_hard_xmit;
-  dev->open = toshoboe_net_open;
-  dev->stop = toshoboe_net_close;
-  dev->do_ioctl = toshoboe_net_ioctl;
+  dev->netdev_ops = &toshoboe_netdev_ops;
 
   err = register_netdev(dev);
   if (err)


