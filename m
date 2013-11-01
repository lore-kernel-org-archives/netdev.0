From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv2 net-next 7/7] smsc9420: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 00:27:23 -0400
Message-ID: <1383280043-13552-8-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:62903 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3KAE1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:27:51 -0400
Received: by mail-qa0-f51.google.com with SMTP id ii20so378022qab.3
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:27:49 -0700 (PDT)
In-Reply-To: <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index e55e336..059bcaf 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -99,17 +99,17 @@ MODULE_PARM_DESC(debug, "debug level");
 
 #define smsc_dbg(TYPE, f, a...) \
 do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_DEBUG PFX f "\n", ## a); \
+		netdev_dbg((pd)->dev, PFX f "\n", ## a); \
 } while (0)
 
 #define smsc_info(TYPE, f, a...) \
 do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_INFO PFX f "\n", ## a); \
+		netdev_info((pd)->dev, PFX f "\n", ## a); \
 } while (0)
 
 #define smsc_warn(TYPE, f, a...) \
 do {	if ((pd)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_WARNING PFX f "\n", ## a); \
+		netdev_warn((pd)->dev, PFX f "\n", ## a); \
 } while (0)
 
 static inline u32 smsc9420_reg_read(struct smsc9420_pdata *pd, u32 offset)
@@ -1168,7 +1168,7 @@ static int smsc9420_mii_probe(struct net_device *dev)
 
 	/* Device only supports internal PHY at address 1 */
 	if (!pd->mii_bus->phy_map[1]) {
-		pr_err("%s: no PHY found at address 1\n", dev->name);
+		netdev_err(dev, "no PHY found at address 1\n");
 		return -ENODEV;
 	}
 
@@ -1180,12 +1180,12 @@ static int smsc9420_mii_probe(struct net_device *dev)
 			     smsc9420_phy_adjust_link, PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(phydev)) {
-		pr_err("%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
-	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		dev->name, phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
+	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		    phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
 
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
@@ -1582,12 +1582,12 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	int result = 0;
 	u32 id_rev;
 
-	printk(KERN_INFO DRV_DESCRIPTION " version " DRV_VERSION "\n");
+	pr_info(DRV_DESCRIPTION " version " DRV_VERSION "\n");
 
 	/* First do the PCI initialisation */
 	result = pci_enable_device(pdev);
 	if (unlikely(result)) {
-		printk(KERN_ERR "Cannot enable smsc9420\n");
+		pr_err("Cannot enable smsc9420\n");
 		goto out_0;
 	}
 
@@ -1600,24 +1600,24 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (!(pci_resource_flags(pdev, SMSC_BAR) & IORESOURCE_MEM)) {
-		printk(KERN_ERR "Cannot find PCI device base address\n");
+		netdev_err(dev, "Cannot find PCI device base address\n");
 		goto out_free_netdev_2;
 	}
 
 	if ((pci_request_regions(pdev, DRV_NAME))) {
-		printk(KERN_ERR "Cannot obtain PCI resources, aborting.\n");
+		netdev_err(dev, "Cannot obtain PCI resources, aborting.\n");
 		goto out_free_netdev_2;
 	}
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_ERR "No usable DMA configuration, aborting.\n");
+		netdev_err(dev, "No usable DMA configuration, aborting.\n");
 		goto out_free_regions_3;
 	}
 
 	virt_addr = ioremap(pci_resource_start(pdev, SMSC_BAR),
 		pci_resource_len(pdev, SMSC_BAR));
 	if (!virt_addr) {
-		printk(KERN_ERR "Cannot map device registers, aborting.\n");
+		netdev_err(dev, "Cannot map device registers, aborting.\n");
 		goto out_free_regions_3;
 	}
 
-- 
1.8.4.2
