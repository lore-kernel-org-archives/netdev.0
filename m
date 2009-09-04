From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 05/29] ioat: kill function prototype ifdef guards
Date: Thu, 03 Sep 2009 19:30:55 -0700
Message-ID: <20090904023055.32667.92412.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932626AbZIDCa7@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The only .c files that utilize these protected prototypes depend on
CONFIG_INTEL_IOATDMA=y, so there is no value gained in providing empty
prototypes.

[ Impact: pure cleanup ]

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.h |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index c5eabae..6e27ddb 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -153,19 +153,10 @@ static inline void ioat_set_tcp_copy_break(struct ioatdma_device *dev)
 	#endif
 }
 
-#if defined(CONFIG_INTEL_IOATDMA) || defined(CONFIG_INTEL_IOATDMA_MODULE)
 struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 				      void __iomem *iobase);
 void ioat_dma_remove(struct ioatdma_device *device);
 struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
-#else
-#define ioat_dma_probe(pdev, iobase)    NULL
-#define ioat_dma_remove(device)         do { } while (0)
-#define ioat_dca_init(pdev, iobase)	NULL
-#define ioat2_dca_init(pdev, iobase)	NULL
-#define ioat3_dca_init(pdev, iobase)	NULL
-#endif
-
 #endif /* IOATDMA_H */
