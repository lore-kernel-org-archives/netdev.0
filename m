From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 6/6] smsc9420: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:27:02 -0400
Message-ID: <1382682422-22677-7-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:58391 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab3JYG10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:26 -0400
Received: by mail-qe0-f44.google.com with SMTP id 6so2117255qeb.3
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:25 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smsc9420.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index e55e336..6840304 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
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
1.8.3.1
