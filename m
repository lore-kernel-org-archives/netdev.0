From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCHv2 10/11]Replace all DMA_24BIT_MASK macro with DMA_BIT_MASK(24)
Date: Thu, 19 Feb 2009 17:51:52 +0800
Message-ID: <499D2BB8.9040503@cn.fujitsu.com>
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
Received: from cn.fujitsu.com ([222.73.24.84]:59428 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbZBSJuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 04:50:25 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_24BIT_MASK macro with DMA_BIT_MASK(24)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 arch/ia64/kernel/pci-dma.c         |    2 +-
 arch/x86/include/asm/dma-mapping.h |    4 ++--
 arch/x86/kernel/pci-dma.c          |    2 +-
 drivers/base/isa.c                 |    2 +-
 drivers/pnp/card.c                 |    2 +-
 drivers/pnp/core.c                 |    2 +-
 sound/pci/als4000.c                |    4 ++--
 sound/pci/azt3328.c                |    4 ++--
 sound/pci/es1938.c                 |    4 ++--
 sound/pci/sonicvibes.c             |    4 ++--
 10 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 0fce76f..3a486fb 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -92,7 +92,7 @@ int iommu_dma_supported(struct device *dev, u64 mask)
 	/* Copied from i386. Doesn't make much sense, because it will
 	   only work for pci_alloc_coherent.
 	   The caller just has to use GFP_DMA in this case. */
-	if (mask < DMA_24BIT_MASK)
+	if (mask < DMA_BIT_MASK(24))
 		return 0;
 
 	/* Tell the device to use SAC when IOMMU force is on.  This
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 0d49479..f26869e 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -244,7 +244,7 @@ static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
 
 	dma_mask = dev->coherent_dma_mask;
 	if (!dma_mask)
-		dma_mask = (gfp & GFP_DMA) ? DMA_24BIT_MASK : DMA_BIT_MASK(32);
+		dma_mask = (gfp & GFP_DMA) ? DMA_BIT_MASK(24) : DMA_BIT_MASK(32);
 
 	return dma_mask;
 }
@@ -253,7 +253,7 @@ static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
 {
 	unsigned long dma_mask = dma_alloc_coherent_mask(dev, gfp);
 
-	if (dma_mask <= DMA_24BIT_MASK)
+	if (dma_mask <= DMA_BIT_MASK(24))
 		gfp |= GFP_DMA;
 #ifdef CONFIG_X86_64
 	if (dma_mask <= DMA_BIT_MASK(32) && !(gfp & GFP_DMA))
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 7aa572f..91f4e46 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -239,7 +239,7 @@ int dma_supported(struct device *dev, u64 mask)
 	/* Copied from i386. Doesn't make much sense, because it will
 	   only work for pci_alloc_coherent.
 	   The caller just has to use GFP_DMA in this case. */
-	if (mask < DMA_24BIT_MASK)
+	if (mask < DMA_BIT_MASK(24))
 		return 0;
 
 	/* Tell the device to use SAC when IOMMU force is on.  This
diff --git a/drivers/base/isa.c b/drivers/base/isa.c
index 479694b..91dba65 100644
--- a/drivers/base/isa.c
+++ b/drivers/base/isa.c
@@ -141,7 +141,7 @@ int isa_register_driver(struct isa_driver *isa_driver, unsigned int ndev)
 		isa_dev->dev.release		= isa_dev_release;
 		isa_dev->id			= id;
 
-		isa_dev->dev.coherent_dma_mask = DMA_24BIT_MASK;
+		isa_dev->dev.coherent_dma_mask = DMA_BIT_MASK(24);
 		isa_dev->dev.dma_mask = &isa_dev->dev.coherent_dma_mask;
 
 		error = device_register(&isa_dev->dev);
diff --git a/drivers/pnp/card.c b/drivers/pnp/card.c
index efea128..4a651f6 100644
--- a/drivers/pnp/card.c
+++ b/drivers/pnp/card.c
@@ -167,7 +167,7 @@ struct pnp_card *pnp_alloc_card(struct pnp_protocol *protocol, int id, char *pnp
 	card->dev.parent = &card->protocol->dev;
 	dev_set_name(&card->dev, "%02x:%02x", card->protocol->number, card->number);
 
-	card->dev.coherent_dma_mask = DMA_24BIT_MASK;
+	card->dev.coherent_dma_mask = DMA_BIT_MASK(24);
 	card->dev.dma_mask = &card->dev.coherent_dma_mask;
 
 	dev_id = pnp_add_card_id(card, pnpid);
diff --git a/drivers/pnp/core.c b/drivers/pnp/core.c
index 14814f2..5dba909 100644
--- a/drivers/pnp/core.c
+++ b/drivers/pnp/core.c
@@ -137,7 +137,7 @@ struct pnp_dev *pnp_alloc_dev(struct pnp_protocol *protocol, int id, char *pnpid
 	INIT_LIST_HEAD(&dev->options);
 	dev->protocol = protocol;
 	dev->number = id;
-	dev->dma_mask = DMA_24BIT_MASK;
+	dev->dma_mask = DMA_BIT_MASK(24);
 
 	dev->dev.parent = &dev->protocol->dev;
 	dev->dev.bus = &pnp_bus_type;
diff --git a/sound/pci/als4000.c b/sound/pci/als4000.c
index ba57005..b3bdf8c 100644
--- a/sound/pci/als4000.c
+++ b/sound/pci/als4000.c
@@ -872,8 +872,8 @@ static int __devinit snd_card_als4000_probe(struct pci_dev *pci,
 		return err;
 	}
 	/* check, if we can restrict PCI DMA transfers to 24 bits */
-	if (pci_set_dma_mask(pci, DMA_24BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_24BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(24)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(24)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 24bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/azt3328.c b/sound/pci/azt3328.c
index 333007c..8522b2f 100644
--- a/sound/pci/azt3328.c
+++ b/sound/pci/azt3328.c
@@ -2125,8 +2125,8 @@ snd_azf3328_create(struct snd_card *card,
 	chip->irq = -1;
 
 	/* check if we can restrict PCI DMA transfers to 24 bits */
-	if (pci_set_dma_mask(pci, DMA_24BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_24BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(24)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(24)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support "
 					"24bit PCI busmaster DMA\n"
 		);
diff --git a/sound/pci/es1938.c b/sound/pci/es1938.c
index 4cd9a1f..34e74e4 100644
--- a/sound/pci/es1938.c
+++ b/sound/pci/es1938.c
@@ -1608,8 +1608,8 @@ static int __devinit snd_es1938_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
         /* check, if we can restrict PCI DMA transfers to 24 bits */
-	if (pci_set_dma_mask(pci, DMA_24BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_24BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(24)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(24)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 24bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
                 return -ENXIO;
diff --git a/sound/pci/sonicvibes.c b/sound/pci/sonicvibes.c
index cd408b8..60079be 100644
--- a/sound/pci/sonicvibes.c
+++ b/sound/pci/sonicvibes.c
@@ -1229,8 +1229,8 @@ static int __devinit snd_sonicvibes_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
 	/* check, if we can restrict PCI DMA transfers to 24 bits */
-        if (pci_set_dma_mask(pci, DMA_24BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_24BIT_MASK) < 0) {
+        if (pci_set_dma_mask(pci, DMA_BIT_MASK(24)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(24)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 24bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
                 return -ENXIO;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
