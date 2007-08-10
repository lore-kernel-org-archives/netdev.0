From: akpm@linux-foundation.org
Subject: [patch 15/18] drivers/net: remove superfluous memset
Date: Fri, 10 Aug 2007 14:05:25 -0700
Message-ID: <200708102105.l7AL5PRA008989@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52120 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759699AbXHJVP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:15:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

	This patch covers something like this:

dev = alloc_*dev(...
...
priv = netdev_priv(dev);
memset(priv, 0, sizeof(*priv));

The memset() here is superfluous. alloc_netdev() uses kzalloc()
to allocate needed memory so there is no need to zero the priv region
twice.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/fs_enet/fs_enet-main.c   |    1 -
 drivers/net/myri10ge/myri10ge.c      |    1 -
 drivers/net/netxen/netxen_nic_main.c |    1 -
 drivers/net/sunlance.c               |    1 -
 drivers/net/usb/pegasus.c            |    1 -
 drivers/net/usb/rtl8150.c            |    1 -
 6 files changed, 6 deletions(-)

diff -puN drivers/net/fs_enet/fs_enet-main.c~drivers-net-remove-superfluous-memset drivers/net/fs_enet/fs_enet-main.c
--- a/drivers/net/fs_enet/fs_enet-main.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/fs_enet/fs_enet-main.c
@@ -962,7 +962,6 @@ static struct net_device *fs_init_instan
 	SET_MODULE_OWNER(ndev);
 
 	fep = netdev_priv(ndev);
-	memset(fep, 0, privsize);	/* clear everything */
 
 	fep->dev = dev;
 	dev_set_drvdata(dev, ndev);
diff -puN drivers/net/myri10ge/myri10ge.c~drivers-net-remove-superfluous-memset drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/myri10ge/myri10ge.c
@@ -2852,7 +2852,6 @@ static int myri10ge_probe(struct pci_dev
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	mgp = netdev_priv(netdev);
-	memset(mgp, 0, sizeof(*mgp));
 	mgp->dev = netdev;
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
diff -puN drivers/net/netxen/netxen_nic_main.c~drivers-net-remove-superfluous-memset drivers/net/netxen/netxen_nic_main.c
--- a/drivers/net/netxen/netxen_nic_main.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/netxen/netxen_nic_main.c
@@ -329,7 +329,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	adapter = netdev->priv;
-	memset(adapter, 0 , sizeof(struct netxen_adapter));
 
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
diff -puN drivers/net/sunlance.c~drivers-net-remove-superfluous-memset drivers/net/sunlance.c
--- a/drivers/net/sunlance.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/sunlance.c
@@ -1335,7 +1335,6 @@ static int __devinit sparc_lance_probe_o
 		return -ENOMEM;
 
 	lp = netdev_priv(dev);
-	memset(lp, 0, sizeof(*lp));
 
 	if (sparc_lance_debug && version_printed++ == 0)
 		printk (KERN_INFO "%s", version);
diff -puN drivers/net/usb/pegasus.c~drivers-net-remove-superfluous-memset drivers/net/usb/pegasus.c
--- a/drivers/net/usb/pegasus.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/usb/pegasus.c
@@ -1306,7 +1306,6 @@ static int pegasus_probe(struct usb_inte
 	}
 
 	pegasus = netdev_priv(net);
-	memset(pegasus, 0, sizeof (struct pegasus));
 	pegasus->dev_index = dev_index;
 	init_waitqueue_head(&pegasus->ctrl_wait);
 
diff -puN drivers/net/usb/rtl8150.c~drivers-net-remove-superfluous-memset drivers/net/usb/rtl8150.c
--- a/drivers/net/usb/rtl8150.c~drivers-net-remove-superfluous-memset
+++ a/drivers/net/usb/rtl8150.c
@@ -905,7 +905,6 @@ static int rtl8150_probe(struct usb_inte
 	}
 
 	dev = netdev_priv(netdev);
-	memset(dev, 0, sizeof(rtl8150_t));
 
 	dev->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
 	if (!dev->intr_buff) {
_
