From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethoc: Remove unused members from struct ethoc
Date: Thu,  5 Jan 2017 09:16:27 +0100
Message-ID: <20170105081627.29146-1-tklauser@distanz.ch>
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        thierry.reding@gmail.com, andrew@lunn.ch, colin.king@canonical.com,
        tremyfr@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:33910 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967288AbdAEIQk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 03:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The io_region_size and dma_alloc members of struct ethoc are only
written but never read, so they might as well be removed.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ethoc.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 45abc81f6f55..63e5e14174ee 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -180,8 +180,6 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
  * struct ethoc - driver-private device structure
  * @iobase:	pointer to I/O memory region
  * @membase:	pointer to buffer memory region
- * @dma_alloc:	dma allocated buffer size
- * @io_region_size:	I/O memory region size
  * @num_bd:	number of buffer descriptors
  * @num_tx:	number of send buffers
  * @cur_tx:	last send buffer written
@@ -199,8 +197,6 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
 struct ethoc {
 	void __iomem *iobase;
 	void __iomem *membase;
-	int dma_alloc;
-	resource_size_t io_region_size;
 	bool big_endian;
 
 	unsigned int num_bd;
@@ -1096,8 +1092,6 @@ static int ethoc_probe(struct platform_device *pdev)
 	/* setup driver-private data */
 	priv = netdev_priv(netdev);
 	priv->netdev = netdev;
-	priv->dma_alloc = 0;
-	priv->io_region_size = resource_size(mmio);
 
 	priv->iobase = devm_ioremap_nocache(&pdev->dev, netdev->base_addr,
 			resource_size(mmio));
@@ -1127,7 +1121,6 @@ static int ethoc_probe(struct platform_device *pdev)
 			goto free;
 		}
 		netdev->mem_end = netdev->mem_start + buffer_size;
-		priv->dma_alloc = buffer_size;
 	}
 
 	priv->big_endian = pdata ? pdata->big_endian :
-- 
2.11.0
