From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 18/29] ioat: ___devinit annotate the initialization paths
Date: Thu, 03 Sep 2009 19:32:01 -0700
Message-ID: <20090904023201.32667.21213.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark all single use initialization routines with __devinit.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dca.c    |    9 ++++++---
 drivers/dma/ioat/dma.c    |   12 ++++++------
 drivers/dma/ioat/dma.h    |   11 ++++++-----
 drivers/dma/ioat/dma_v2.c |    4 ++--
 drivers/dma/ioat/dma_v2.h |    8 ++++----
 5 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/dma/ioat/dca.c b/drivers/dma/ioat/dca.c
index af1c762..69d0261 100644
--- a/drivers/dma/ioat/dca.c
+++ b/drivers/dma/ioat/dca.c
@@ -242,7 +242,8 @@ static struct dca_ops ioat_dca_ops = {
 };
 
 
-struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase)
+struct dca_provider * __devinit
+ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 {
 	struct dca_provider *dca;
 	struct ioat_dca_priv *ioatdca;
@@ -407,7 +408,8 @@ static int ioat2_dca_count_dca_slots(void __iomem *iobase, u16 dca_offset)
 	return slots;
 }
 
-struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase)
+struct dca_provider * __devinit
+ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 {
 	struct dca_provider *dca;
 	struct ioat_dca_priv *ioatdca;
@@ -602,7 +604,8 @@ static int ioat3_dca_count_dca_slots(void *iobase, u16 dca_offset)
 	return slots;
 }
 
-struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
+struct dca_provider * __devinit
+ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 {
 	struct dca_provider *dca;
 	struct ioat_dca_priv *ioatdca;
diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 6dd0af1..abc96c4 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -870,7 +870,7 @@ static void ioat1_dma_start_null_desc(struct ioat_dma_chan *ioat)
  */
 #define IOAT_TEST_SIZE 2000
 
-static void ioat_dma_test_callback(void *dma_async_param)
+static void __devinit ioat_dma_test_callback(void *dma_async_param)
 {
 	struct completion *cmp = dma_async_param;
 
@@ -881,7 +881,7 @@ static void ioat_dma_test_callback(void *dma_async_param)
  * ioat_dma_self_test - Perform a IOAT transaction to verify the HW works.
  * @device: device to be tested
  */
-static int ioat_dma_self_test(struct ioatdma_device *device)
+static int __devinit ioat_dma_self_test(struct ioatdma_device *device)
 {
 	int i;
 	u8 *src;
@@ -1082,7 +1082,7 @@ static void ioat_disable_interrupts(struct ioatdma_device *device)
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
 }
 
-int ioat_probe(struct ioatdma_device *device)
+int __devinit ioat_probe(struct ioatdma_device *device)
 {
 	int err = -ENODEV;
 	struct dma_device *dma = &device->common;
@@ -1142,7 +1142,7 @@ err_dma_pool:
 	return err;
 }
 
-int ioat_register(struct ioatdma_device *device)
+int __devinit ioat_register(struct ioatdma_device *device)
 {
 	int err = dma_async_device_register(&device->common);
 
@@ -1169,7 +1169,7 @@ static void ioat1_intr_quirk(struct ioatdma_device *device)
 	pci_write_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, dmactrl);
 }
 
-int ioat1_dma_probe(struct ioatdma_device *device, int dca)
+int __devinit ioat1_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
 	struct dma_device *dma;
@@ -1200,7 +1200,7 @@ int ioat1_dma_probe(struct ioatdma_device *device, int dca)
 	return err;
 }
 
-void ioat_dma_remove(struct ioatdma_device *device)
+void __devexit ioat_dma_remove(struct ioatdma_device *device)
 {
 	struct dma_device *dma = &device->common;
 
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 5fd6e2d..e47083b 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -217,11 +217,12 @@ ioat_chan_by_index(struct ioatdma_device *device, int index)
 	return device->idx[index];
 }
 
-int ioat_probe(struct ioatdma_device *device);
-int ioat_register(struct ioatdma_device *device);
-int ioat1_dma_probe(struct ioatdma_device *dev, int dca);
-void ioat_dma_remove(struct ioatdma_device *device);
-struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+int __devinit ioat_probe(struct ioatdma_device *device);
+int __devinit ioat_register(struct ioatdma_device *device);
+int __devinit ioat1_dma_probe(struct ioatdma_device *dev, int dca);
+void __devexit ioat_dma_remove(struct ioatdma_device *device);
+struct dca_provider * __devinit ioat_dca_init(struct pci_dev *pdev,
+					      void __iomem *iobase);
 unsigned long ioat_get_current_completion(struct ioat_chan_common *chan);
 void ioat_init_channel(struct ioatdma_device *device,
 		       struct ioat_chan_common *chan, int idx,
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index be617db..a0def66 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -684,7 +684,7 @@ ioat2_is_complete(struct dma_chan *c, dma_cookie_t cookie,
 	return ioat_is_complete(c, cookie, done, used);
 }
 
-int ioat2_dma_probe(struct ioatdma_device *device, int dca)
+int __devinit ioat2_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
 	struct dma_device *dma;
@@ -723,7 +723,7 @@ int ioat2_dma_probe(struct ioatdma_device *device, int dca)
 	return err;
 }
 
-int ioat3_dma_probe(struct ioatdma_device *device, int dca)
+int __devinit ioat3_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
 	struct dma_device *dma;
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index c72ccb5..bdde537 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -127,8 +127,8 @@ ioat2_get_ring_ent(struct ioat2_dma_chan *ioat, u16 idx)
 	return ioat->ring[idx & ioat2_ring_mask(ioat)];
 }
 
-int ioat2_dma_probe(struct ioatdma_device *dev, int dca);
-int ioat3_dma_probe(struct ioatdma_device *dev, int dca);
-struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
-struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+int __devinit ioat2_dma_probe(struct ioatdma_device *dev, int dca);
+int __devinit ioat3_dma_probe(struct ioatdma_device *dev, int dca);
+struct dca_provider * __devinit ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+struct dca_provider * __devinit ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 #endif /* IOATDMA_V2_H */

