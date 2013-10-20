From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 9/9] bnx2x: Set NETIF_F_HIGHDMA unconditionally
Date: Sun, 20 Oct 2013 16:51:34 +0200
Message-ID: <1382280694-8428-10-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2400 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab3JTOwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:52:05 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Merav Sicron <meravs@broadcom.com>

Current driver implementation incorrectly sets the flag only if 64-bit
DMA mask succeeded.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 +---
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 310c57a..c5e375d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1528,7 +1528,6 @@ struct bnx2x {
 #define PCI_32BIT_FLAG			(1 << 1)
 #define ONE_PORT_FLAG			(1 << 2)
 #define NO_WOL_FLAG			(1 << 3)
-#define USING_DAC_FLAG			(1 << 4)
 #define USING_MSIX_FLAG			(1 << 5)
 #define USING_MSI_FLAG			(1 << 6)
 #define DISABLE_MSI_FLAG		(1 << 7)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7a66bd2..b42f89c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12118,7 +12118,6 @@ static int bnx2x_set_coherency_mask(struct bnx2x *bp)
 	struct device *dev = &bp->pdev->dev;
 
 	if (dma_set_mask(dev, DMA_BIT_MASK(64)) == 0) {
-		bp->flags |= USING_DAC_FLAG;
 		if (dma_set_coherent_mask(dev, DMA_BIT_MASK(64)) != 0) {
 			dev_err(dev, "dma_set_coherent_mask failed, aborting\n");
 			return -EIO;
@@ -12286,8 +12285,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
 
 	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_CTAG_RX;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 
 	/* Add Loopback capability to the device */
 	dev->hw_features |= NETIF_F_LOOPBACK;
-- 
1.8.1.227.g44fe835
