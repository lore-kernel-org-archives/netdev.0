From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCHv2 08/11]Replace all DMA_30BIT_MASK macro with DMA_BIT_MASK(30)
Date: Thu, 19 Feb 2009 17:48:45 +0800
Message-ID: <499D2AFD.3050403@cn.fujitsu.com>
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
Received: from cn.fujitsu.com ([222.73.24.84]:53093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbZBSJrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 04:47:18 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_30BIT_MASK macro with DMA_BIT_MASK(30)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/b44.c                    |   14 +++++++-------
 drivers/net/wireless/b43/dma.c       |    6 +++---
 drivers/net/wireless/b43legacy/dma.c |    6 +++---
 sound/pci/sis7019.c                  |    2 +-
 sound/pci/trident/trident_main.c     |    4 ++--
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index c38512e..025fa38 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -660,7 +660,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
 	if (ssb_dma_mapping_error(bp->sdev, mapping) ||
-		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
+		mapping + RX_PKT_BUF_SZ > DMA_BIT_MASK(30)) {
 		/* Sigh... */
 		if (!ssb_dma_mapping_error(bp->sdev, mapping))
 			ssb_dma_unmap_single(bp->sdev, mapping,
@@ -673,7 +673,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 					     RX_PKT_BUF_SZ,
 					     DMA_FROM_DEVICE);
 		if (ssb_dma_mapping_error(bp->sdev, mapping) ||
-			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
+			mapping + RX_PKT_BUF_SZ > DMA_BIT_MASK(30)) {
 			if (!ssb_dma_mapping_error(bp->sdev, mapping))
 				ssb_dma_unmap_single(bp->sdev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
@@ -965,7 +965,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	mapping = ssb_dma_map_single(bp->sdev, skb->data, len, DMA_TO_DEVICE);
-	if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_30BIT_MASK) {
+	if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
 		struct sk_buff *bounce_skb;
 
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
@@ -979,7 +979,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		mapping = ssb_dma_map_single(bp->sdev, bounce_skb->data,
 					     len, DMA_TO_DEVICE);
-		if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_30BIT_MASK) {
+		if (ssb_dma_mapping_error(bp->sdev, mapping) || mapping + len > DMA_BIT_MASK(30)) {
 			if (!ssb_dma_mapping_error(bp->sdev, mapping))
 				ssb_dma_unmap_single(bp->sdev, mapping,
 						     len, DMA_TO_DEVICE);
@@ -1204,7 +1204,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 						 DMA_BIDIRECTIONAL);
 
 		if (ssb_dma_mapping_error(bp->sdev, rx_ring_dma) ||
-			rx_ring_dma + size > DMA_30BIT_MASK) {
+			rx_ring_dma + size > DMA_BIT_MASK(30)) {
 			kfree(rx_ring);
 			goto out_err;
 		}
@@ -1231,7 +1231,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 			                    DMA_TO_DEVICE);
 
 		if (ssb_dma_mapping_error(bp->sdev, tx_ring_dma) ||
-			tx_ring_dma + size > DMA_30BIT_MASK) {
+			tx_ring_dma + size > DMA_BIT_MASK(30)) {
 			kfree(tx_ring);
 			goto out_err;
 		}
@@ -2176,7 +2176,7 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 			"Failed to powerup the bus\n");
 		goto err_out_free_dev;
 	}
-	err = ssb_dma_set_mask(sdev, DMA_30BIT_MASK);
+	err = ssb_dma_set_mask(sdev, DMA_BIT_MASK(30));
 	if (err) {
 		dev_err(sdev->dev,
 			"Required 30BIT DMA mask unsupported by the system.\n");
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 87671d8..a1195e4 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -776,12 +776,12 @@ static u64 supported_dma_mask(struct b43_wldev *dev)
 	if (tmp & B43_DMA32_TXADDREXT_MASK)
 		return DMA_BIT_MASK(32);
 
-	return DMA_30BIT_MASK;
+	return DMA_BIT_MASK(30);
 }
 
 static enum b43_dmatype dma_mask_to_engine_type(u64 dmamask)
 {
-	if (dmamask == DMA_30BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(30))
 		return B43_DMA_30BIT;
 	if (dmamask == DMA_BIT_MASK(32))
 		return B43_DMA_32BIT;
@@ -1002,7 +1002,7 @@ static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 			continue;
 		}
 		if (mask == DMA_BIT_MASK(32)) {
-			mask = DMA_30BIT_MASK;
+			mask = DMA_BIT_MASK(30);
 			fallback = 1;
 			continue;
 		}
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 1d3e0d2..2f90fb9 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -856,12 +856,12 @@ static u64 supported_dma_mask(struct b43legacy_wldev *dev)
 	if (tmp & B43legacy_DMA32_TXADDREXT_MASK)
 		return DMA_BIT_MASK(32);
 
-	return DMA_30BIT_MASK;
+	return DMA_BIT_MASK(30);
 }
 
 static enum b43legacy_dmatype dma_mask_to_engine_type(u64 dmamask)
 {
-	if (dmamask == DMA_30BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(30))
 		return B43legacy_DMA_30BIT;
 	if (dmamask == DMA_BIT_MASK(32))
 		return B43legacy_DMA_32BIT;
@@ -1048,7 +1048,7 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 			continue;
 		}
 		if (mask == DMA_BIT_MASK(32)) {
-			mask = DMA_30BIT_MASK;
+			mask = DMA_BIT_MASK(30);
 			fallback = 1;
 			continue;
 		}
diff --git a/sound/pci/sis7019.c b/sound/pci/sis7019.c
index df2007e..c802652 100644
--- a/sound/pci/sis7019.c
+++ b/sound/pci/sis7019.c
@@ -1300,7 +1300,7 @@ static int __devinit sis_chip_create(struct snd_card *card,
 	if (rc)
 		goto error_out;
 
-	if (pci_set_dma_mask(pci, DMA_30BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(30)) < 0) {
 		printk(KERN_ERR "sis7019: architecture does not support "
 					"30-bit PCI busmaster DMA");
 		goto error_out_enabled;
diff --git a/sound/pci/trident/trident_main.c b/sound/pci/trident/trident_main.c
index c612b43..1724789 100644
--- a/sound/pci/trident/trident_main.c
+++ b/sound/pci/trident/trident_main.c
@@ -3554,8 +3554,8 @@ int __devinit snd_trident_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
 	/* check, if we can restrict PCI DMA transfers to 30 bits */
-	if (pci_set_dma_mask(pci, DMA_30BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_30BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(30)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(30)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 30bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
