From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: Fix 64bit compiler warnings
Date: Sun, 4 Jun 2006 12:03:56 +0200
Message-ID: <200606041203.57205.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27618
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751390AbWFDKEV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 06:04:21 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix all 64bit compiler warnings.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
index e882bc1..0f7303e 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
@@ -227,7 +227,7 @@ static ssize_t tsf_write_file(struct fil
 		res = -EFAULT;
 		goto out_unlock;
 	}
-	if (sscanf(buf, "%lli", &tsf) != 1) {
+	if (sscanf(buf, "%llu", (unsigned long long *)(&tsf)) != 1) {
 		printk(KERN_INFO PFX "debugfs: invalid values for \"tsf\"\n");
 		res = -EINVAL;
 		goto out_unlock;
@@ -449,11 +449,11 @@ void bcm43xx_printk_dump(const char *dat
 			 size_t size,
 			 const char *description)
 {
-	size_t i;
+	unsigned int i;
 	char c;
 
-	printk(KERN_INFO PFX "Data dump (%s, %u bytes):",
-	       description, size);
+	printk(KERN_INFO PFX "Data dump (%s, %lu bytes):",
+	       description, (unsigned long)size);
 	for (i = 0; i < size; i++) {
 		c = data[i];
 		if (i % 8 == 0)
@@ -468,12 +468,13 @@ void bcm43xx_printk_bitdump(const unsign
 			    size_t bytes, int msb_to_lsb,
 			    const char *description)
 {
-	size_t i;
+	unsigned int i;
 	int j;
 	const unsigned char *d;
 
-	printk(KERN_INFO PFX "*** Bitdump (%s, %u bytes, %s) ***",
-	       description, bytes, msb_to_lsb ? "MSB to LSB" : "LSB to MSB");
+	printk(KERN_INFO PFX "*** Bitdump (%s, %lu bytes, %s) ***",
+	       description, (unsigned long)bytes,
+	       msb_to_lsb ? "MSB to LSB" : "LSB to MSB");
 	for (i = 0; i < bytes; i++) {
 		d = data + i;
 		if (i % 8 == 0)
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
index dc11260..1dfd74e 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -180,7 +180,7 @@ static int alloc_ringmemory(struct bcm43
 	if (ring->dmabase + BCM43xx_DMA_RINGMEMSIZE > BCM43xx_DMA_BUSADDRMAX) {
 		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA RINGMEMORY >1G "
 				    "(0x%08x, len: %lu)\n",
-		       ring->dmabase, BCM43xx_DMA_RINGMEMSIZE);
+		       (unsigned int)ring->dmabase, BCM43xx_DMA_RINGMEMSIZE);
 		dma_free_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
 				  ring->vbase, ring->dmabase);
 		return -ENOMEM;
@@ -292,7 +292,7 @@ static int setup_rx_descbuffer(struct bc
 		dev_kfree_skb_any(skb);
 		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA RX SKB >1G "
 				    "(0x%08x, len: %u)\n",
-		       dmaaddr, ring->rx_buffersize);
+		       (unsigned int)dmaaddr, ring->rx_buffersize);
 		return -ENOMEM;
 	}
 	meta->skb = skb;
@@ -711,7 +711,7 @@ static int dma_tx_fragment(struct bcm43x
 		dev_kfree_skb_irq(hdr_skb);
 		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA TX SKB >1G "
 				    "(0x%08x, len: %u)\n",
-		       meta->dmaaddr, hdr_skb->len);
+		       (unsigned int)meta->dmaaddr, hdr_skb->len);
 		return -ENOMEM;
 	}
 
@@ -742,7 +742,7 @@ static int dma_tx_fragment(struct bcm43x
 		dev_kfree_skb_irq(hdr_skb);
 		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA TX SKB >1G "
 				    "(0x%08x, len: %u)\n",
-		       meta->dmaaddr, skb->len);
+		       (unsigned int)meta->dmaaddr, skb->len);
 		return -ENOMEM;
 	}
 

-- 
Greetings Michael.
