From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 03/12]Replace all DMA_40BIT_MASK micro with DMA_BIT_MASK(40)
Date: Thu, 19 Feb 2009 14:41:53 +0800
Message-ID: <499CFF31.6030304@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63210 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbZBSGk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:40:26 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_40BIT_MASK micro with DMA_BIT_MASK(40)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 arch/ia64/kernel/pci-dma.c          |    2 +-
 arch/x86/kernel/pci-dma.c           |    2 +-
 drivers/net/bnx2.c                  |    2 +-
 drivers/net/enic/enic_main.c        |    4 ++--
 drivers/net/ipg.c                   |    2 +-
 drivers/net/tg3.c                   |    6 +++---
 drivers/scsi/sym53c8xx_2/sym_hipd.h |    2 +-
 7 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index d0ada06..885707a 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -107,7 +107,7 @@ int iommu_dma_supported(struct device *dev, u64 mask)
 	   SAC for these.  Assume all masks <= 40 bits are of this
 	   type. Normally this doesn't make any difference, but gives
 	   more gentle handling of IOMMU overflow. */
-	if (iommu_sac_force && (mask >= DMA_40BIT_MASK)) {
+	if (iommu_sac_force && (mask >= DMA_BIT_MASK(40))) {
 		dev_info(dev, "Force SAC with mask %lx\n", mask);
 		return 0;
 	}
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index b254285..5824b44 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -254,7 +254,7 @@ int dma_supported(struct device *dev, u64 mask)
 	   SAC for these.  Assume all masks <= 40 bits are of this
 	   type. Normally this doesn't make any difference, but gives
 	   more gentle handling of IOMMU overflow. */
-	if (iommu_sac_force && (mask >= DMA_40BIT_MASK)) {
+	if (iommu_sac_force && (mask >= DMA_BIT_MASK(40))) {
 		dev_info(dev, "Force SAC with mask %Lx\n", mask);
 		return 0;
 	}
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 696e7bf..e12b65f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7461,7 +7461,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	/* 5708 cannot support DMA addresses > 40-bit.  */
 	if (CHIP_NUM(bp) == CHIP_NUM_5708)
-		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 	else
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 7d60551..c97f87d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1670,7 +1670,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	 * fail to 32-bit.
 	 */
 
-	err = pci_set_dma_mask(pdev, DMA_40BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
@@ -1686,7 +1686,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 			goto err_out_release_regions;
 		}
 	} else {
-		err = pci_set_consistent_dma_mask(pdev, DMA_40BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(40));
 		if (err) {
 			printk(KERN_ERR PFX
 				"Unable to obtain 40-bit DMA "
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 360aa5e..ed9ded9 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -2240,7 +2240,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	rc = pci_set_dma_mask(pdev, DMA_40BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
 	if (rc < 0) {
 		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc < 0) {
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 488ecb7..dd9164c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4781,7 +4781,7 @@ static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 {
 #if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
 	if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG)
-		return (((u64) mapping + len) > DMA_40BIT_MASK);
+		return (((u64) mapping + len) > DMA_BIT_MASK(40));
 	return 0;
 #else
 	return 0;
@@ -13104,7 +13104,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	if (tp->tg3_flags2 & TG3_FLG2_IS_5788)
 		persist_dma_mask = dma_mask = DMA_32BIT_MASK;
 	else if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG) {
-		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 #ifdef CONFIG_HIGHMEM
 		dma_mask = DMA_BIT_MASK(64);
 #endif
@@ -13265,7 +13265,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	printk(KERN_INFO "%s: dma_rwctrl[%08x] dma_mask[%d-bit]\n",
 	       dev->name, tp->dma_rwctrl,
 	       (pdev->dma_mask == DMA_32BIT_MASK) ? 32 :
-	        (((u64) pdev->dma_mask == DMA_40BIT_MASK) ? 40 : 64));
+	        (((u64) pdev->dma_mask == DMA_BIT_MASK(40)) ? 40 : 64));
 
 	return 0;
 
diff --git a/drivers/scsi/sym53c8xx_2/sym_hipd.h b/drivers/scsi/sym53c8xx_2/sym_hipd.h
index a0c8f3a..61e8848 100644
--- a/drivers/scsi/sym53c8xx_2/sym_hipd.h
+++ b/drivers/scsi/sym53c8xx_2/sym_hipd.h
@@ -1083,7 +1083,7 @@ do {						\
 	(data)->size = cpu_to_scr(len);		\
 } while (0)
 #elif SYM_CONF_DMA_ADDRESSING_MODE == 1
-#define DMA_DAC_MASK	DMA_40BIT_MASK
+#define DMA_DAC_MASK	DMA_BIT_MASK(40)
 #define sym_build_sge(np, data, badd, len)				\
 do {									\
 	(data)->addr = cpu_to_scr(badd);				\
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
