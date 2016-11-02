From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v2 01/26] swiotlb: Drop unused functions swiotlb_map_sg
 and swiotlb_unmap_sg
Date: Wed, 02 Nov 2016 07:12:31 -0400
Message-ID: <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are no users for swiotlb_map_sg or swiotlb_unmap_sg so we might as
well just drop them.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Added swiotlb_unmap_sg to functions dropped.

 include/linux/swiotlb.h |    8 --------
 lib/swiotlb.c           |   16 ----------------
 2 files changed, 24 deletions(-)

diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 5f81f8a..f0d2589 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -73,14 +73,6 @@ extern void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			       unsigned long attrs);
 
 extern int
-swiotlb_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-	       enum dma_data_direction dir);
-
-extern void
-swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-		 enum dma_data_direction dir);
-
-extern int
 swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 		     enum dma_data_direction dir,
 		     unsigned long attrs);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 22e13a0..5005316 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -910,14 +910,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 }
 EXPORT_SYMBOL(swiotlb_map_sg_attrs);
 
-int
-swiotlb_map_sg(struct device *hwdev, struct scatterlist *sgl, int nelems,
-	       enum dma_data_direction dir)
-{
-	return swiotlb_map_sg_attrs(hwdev, sgl, nelems, dir, 0);
-}
-EXPORT_SYMBOL(swiotlb_map_sg);
-
 /*
  * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
  * concerning calls here are the same as for swiotlb_unmap_page() above.
@@ -938,14 +930,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 }
 EXPORT_SYMBOL(swiotlb_unmap_sg_attrs);
 
-void
-swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sgl, int nelems,
-		 enum dma_data_direction dir)
-{
-	return swiotlb_unmap_sg_attrs(hwdev, sgl, nelems, dir, 0);
-}
-EXPORT_SYMBOL(swiotlb_unmap_sg);
-
 /*
  * Make physical memory consistent for a set of streaming mode DMA translations
  * after a transfer.
