From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 36/37] arch/microblaze: Remove .archdata.of_node and use
	.of_node in struct device
Date: Thu, 11 Mar 2010 11:07:06 -0700
Message-ID: <20100311180706.4824.39674.stgit__40272.2408799038$1268330903$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44941 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933847Ab0CKSHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:07:20 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.archdata.of_node is being removed from Microblaze, SPARC and PowerPC
because it duplicates the struct device .of_node pointer.  This patch
also removes .node from struct of_device for the same reason.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/microblaze/include/asm/device.h    |    8 --------
 arch/microblaze/include/asm/of_device.h |    1 -
 arch/microblaze/kernel/of_device.c      |    4 +---
 3 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/arch/microblaze/include/asm/device.h b/arch/microblaze/include/asm/device.h
index 2370888..8d46822 100644
--- a/arch/microblaze/include/asm/device.h
+++ b/arch/microblaze/include/asm/device.h
@@ -12,19 +12,11 @@
 struct device_node;
 
 struct dev_archdata {
-	/* Optional pointer to an OF device node */
-	struct device_node	*of_node;
 };
 
 struct pdev_archdata {
 };
 
-static inline void dev_archdata_set_node(struct dev_archdata *ad,
-					 struct device_node *np)
-{
-	ad->of_node = np;
-}
-
 #endif /* _ASM_MICROBLAZE_DEVICE_H */
 
 
diff --git a/arch/microblaze/include/asm/of_device.h b/arch/microblaze/include/asm/of_device.h
index ba917cf..ab25a40 100644
--- a/arch/microblaze/include/asm/of_device.h
+++ b/arch/microblaze/include/asm/of_device.h
@@ -21,7 +21,6 @@
  * probed using OF properties.
  */
 struct of_device {
-	struct device_node	*node; /* to be obsoleted */
 	u64			dma_mask; /* DMA mask */
 	struct device		dev; /* Generic device interface */
 };
diff --git a/arch/microblaze/kernel/of_device.c b/arch/microblaze/kernel/of_device.c
index ae165fc..ac7e6e1 100644
--- a/arch/microblaze/kernel/of_device.c
+++ b/arch/microblaze/kernel/of_device.c
@@ -49,12 +49,10 @@ struct of_device *of_device_alloc(struct device_node *np,
 	if (!dev)
 		return NULL;
 
-	dev->node = of_node_get(np);
+	dev->dev.of_node = of_node_get(np);
 	dev->dev.dma_mask = &dev->dma_mask;
 	dev->dev.parent = parent;
 	dev->dev.release = of_release_dev;
-	dev->dev.archdata.of_node = np; /* temporary; remove after merging */
-	dev->dev.of_node = np;
 
 	if (bus_id)
 		dev_set_name(&dev->dev, bus_id);

