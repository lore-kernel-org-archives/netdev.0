From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCHv2 04/11]Replace all DMA_39BIT_MASK macro with DMA_BIT_MASK(39)
Date: Thu, 19 Feb 2009 17:42:13 +0800
Message-ID: <499D2975.6000708@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com> <20090219081403.GA5400@elte.hu> <499D1ED9.4040005@cn.fujitsu.com> <499D2728.1080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60258 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbZBSJky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 04:40:54 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_39BIT_MASK macro with DMA_BIT_MASK(39)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/forcedeth.c                |    4 ++--
 drivers/net/netxen/netxen_nic_main.c   |    8 ++++----
 drivers/scsi/aic7xxx/aic79xx_osm_pci.c |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 5b910cf..069d87d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5534,12 +5534,12 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->desc_ver = DESC_VER_3;
 		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 		if (dma_64bit) {
-			if (pci_set_dma_mask(pci_dev, DMA_39BIT_MASK))
+			if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(39)))
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA failed, using 32-bit addressing\n");
 			else
 				dev->features |= NETIF_F_HIGHDMA;
-			if (pci_set_consistent_dma_mask(pci_dev, DMA_39BIT_MASK)) {
+			if (pci_set_consistent_dma_mask(pci_dev, DMA_BIT_MASK(39))) {
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
 			}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 285e725..8bea4cb 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -177,11 +177,11 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 #else
 	if (revision_id >= NX_P3_B0) {
 		/* should go to DMA_BIT_MASK(64) */
-		adapter->dma_mask = DMA_39BIT_MASK;
-		mask = DMA_39BIT_MASK;
+		adapter->dma_mask = DMA_BIT_MASK(39);
+		mask = DMA_BIT_MASK(39);
 	} else if (revision_id == NX_P3_A2) {
-		adapter->dma_mask = DMA_39BIT_MASK;
-		mask = DMA_39BIT_MASK;
+		adapter->dma_mask = DMA_BIT_MASK(39);
+		mask = DMA_BIT_MASK(39);
 	} else if (revision_id == NX_P2_C1) {
 		adapter->dma_mask = DMA_35BIT_MASK;
 		mask = DMA_35BIT_MASK;
diff --git a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
index 032e2b1..c583d89 100644
--- a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
+++ b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
@@ -194,11 +194,11 @@ ahd_linux_pci_dev_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (sizeof(dma_addr_t) > 4) {
 		const u64 required_mask = dma_get_required_mask(dev);
 
-		if (required_mask > DMA_39BIT_MASK &&
+		if (required_mask > DMA_BIT_MASK(39) &&
 		    dma_set_mask(dev, DMA_BIT_MASK(64)) == 0)
 			ahd->flags |= AHD_64BIT_ADDRESSING;
 		else if (required_mask > DMA_32BIT_MASK &&
-			 dma_set_mask(dev, DMA_39BIT_MASK) == 0)
+			 dma_set_mask(dev, DMA_BIT_MASK(39)) == 0)
 			ahd->flags |= AHD_39BIT_ADDRESSING;
 		else
 			dma_set_mask(dev, DMA_32BIT_MASK);
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
