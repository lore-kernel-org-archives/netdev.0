From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] ixgbe: potential null dereference
Date: Tue, 27 Jul 2010 12:05:56 +0200
Message-ID: <20100727100556.GM26313@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43603 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab0G0KGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 06:06:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The e_dev_err() macro dereferences "adapter" which is NULL here.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9203759..0360260 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6549,8 +6549,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			err = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
 			if (err) {
-				e_dev_err("No usable DMA configuration, "
-					  "aborting\n");
+				dev_err(&pdev->dev,
+					"No usable DMA configuration, aborting\n");
 				goto err_dma;
 			}
 		}
@@ -6560,7 +6560,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
 	                                   IORESOURCE_MEM), ixgbe_driver_name);
 	if (err) {
-		e_dev_err("pci_request_selected_regions failed 0x%x\n", err);
+		dev_err(&pdev->dev,
+			"pci_request_selected_regions failed 0x%x\n", err);
 		goto err_pci_reg;
 	}
 
