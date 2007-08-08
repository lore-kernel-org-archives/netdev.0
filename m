From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] drivers/net: remove superfluous memset
Date: Wed, 8 Aug 2007 09:38:52 +0200
Message-ID: <200708080938.52300.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:3378 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758849AbXHHHiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 03:38:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	This patch covers sth like this:

dev = alloc_*dev(...
...
priv = netdev_priv(dev);
memset(priv, 0, sizeof(*priv));

The memset() here is superfluous. alloc_netdev() uses kzalloc()
to allocate needed memory so there is no need to zero the priv region
twice.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/fs_enet/fs_enet-main.c   |    1 -
 drivers/net/myri10ge/myri10ge.c      |    1 -
 drivers/net/netxen/netxen_nic_main.c |    1 -
 drivers/net/sunlance.c               |    1 -
 drivers/net/usb/pegasus.c            |    1 -
 drivers/net/usb/rtl8150.c            |    1 -
 6 files changed, 6 deletions(-)

diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/fs_enet/fs_enet-main.c linux-2.6.23-rc1-mm2-b/drivers/net/fs_enet/fs_enet-main.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/fs_enet/fs_enet-main.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/fs_enet/fs_enet-main.c	2007-08-07 01:26:12.000000000 +0200
@@ -962,7 +962,6 @@ static struct net_device *fs_init_instan
 	SET_MODULE_OWNER(ndev);
 
 	fep = netdev_priv(ndev);
-	memset(fep, 0, privsize);	/* clear everything */
 
 	fep->dev = dev;
 	dev_set_drvdata(dev, ndev);
diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/myri10ge/myri10ge.c linux-2.6.23-rc1-mm2-b/drivers/net/myri10ge/myri10ge.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/myri10ge/myri10ge.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/myri10ge/myri10ge.c	2007-08-07 01:24:49.000000000 +0200
@@ -2852,7 +2852,6 @@ static int myri10ge_probe(struct pci_dev
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	mgp = netdev_priv(netdev);
-	memset(mgp, 0, sizeof(*mgp));
 	mgp->dev = netdev;
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/netxen/netxen_nic_main.c linux-2.6.23-rc1-mm2-b/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/netxen/netxen_nic_main.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/netxen/netxen_nic_main.c	2007-08-07 01:06:57.000000000 +0200
@@ -329,7 +329,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	adapter = netdev->priv;
-	memset(adapter, 0 , sizeof(struct netxen_adapter));
 
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/sunlance.c linux-2.6.23-rc1-mm2-b/drivers/net/sunlance.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/sunlance.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/sunlance.c	2007-08-07 01:20:37.000000000 +0200
@@ -1335,7 +1335,6 @@ static int __devinit sparc_lance_probe_o
 		return -ENOMEM;
 
 	lp = netdev_priv(dev);
-	memset(lp, 0, sizeof(*lp));
 
 	if (sparc_lance_debug && version_printed++ == 0)
 		printk (KERN_INFO "%s", version);
diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/usb/pegasus.c linux-2.6.23-rc1-mm2-b/drivers/net/usb/pegasus.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/usb/pegasus.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/usb/pegasus.c	2007-08-07 01:16:44.000000000 +0200
@@ -1306,7 +1306,6 @@ static int pegasus_probe(struct usb_inte
 	}
 
 	pegasus = netdev_priv(net);
-	memset(pegasus, 0, sizeof (struct pegasus));
 	pegasus->dev_index = dev_index;
 	init_waitqueue_head(&pegasus->ctrl_wait);
 
diff -upr linux-2.6.23-rc1-mm2-a/drivers/net/usb/rtl8150.c linux-2.6.23-rc1-mm2-b/drivers/net/usb/rtl8150.c
--- linux-2.6.23-rc1-mm2-a/drivers/net/usb/rtl8150.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/usb/rtl8150.c	2007-08-07 01:15:51.000000000 +0200
@@ -905,7 +905,6 @@ static int rtl8150_probe(struct usb_inte
 	}
 
 	dev = netdev_priv(netdev);
-	memset(dev, 0, sizeof(rtl8150_t));
 
 	dev->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
 	if (!dev->intr_buff) {
