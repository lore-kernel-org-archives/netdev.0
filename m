From: Joe Perches <joe@perches.com>
Subject: [PATCH 31/49] drivers/net/vxge: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:55 -0700
Message-ID: <172075d8c39f4abb1533a483862d2e394fec5999.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vxge/vxge-config.c |   37 +++++++++----------------------------
 1 files changed, 9 insertions(+), 28 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 906a3ca3..0c0a4e4 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -776,14 +776,12 @@ vxge_hw_device_initialize(
 	if (status != VXGE_HW_OK)
 		goto exit;
 
-	hldev = (struct __vxge_hw_device *)
-			vmalloc(sizeof(struct __vxge_hw_device));
+	hldev = vzalloc(sizeof(struct __vxge_hw_device));
 	if (hldev == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
 	}
 
-	memset(hldev, 0, sizeof(struct __vxge_hw_device));
 	hldev->magic = VXGE_HW_DEVICE_MAGIC;
 
 	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_ALL);
@@ -1627,15 +1625,12 @@ __vxge_hw_mempool_grow(struct vxge_hw_mempool *mempool, u32 num_allocate,
 		 * allocate new memblock and its private part at once.
 		 * This helps to minimize memory usage a lot. */
 		mempool->memblocks_priv_arr[i] =
-				vmalloc(mempool->items_priv_size * n_items);
+				vzalloc(mempool->items_priv_size * n_items);
 		if (mempool->memblocks_priv_arr[i] == NULL) {
 			status = VXGE_HW_ERR_OUT_OF_MEMORY;
 			goto exit;
 		}
 
-		memset(mempool->memblocks_priv_arr[i], 0,
-			     mempool->items_priv_size * n_items);
-
 		/* allocate DMA-capable memblock */
 		mempool->memblocks_arr[i] =
 			__vxge_hw_blockpool_malloc(mempool->devh,
@@ -1707,13 +1702,11 @@ __vxge_hw_mempool_create(
 		goto exit;
 	}
 
-	mempool = (struct vxge_hw_mempool *)
-			vmalloc(sizeof(struct vxge_hw_mempool));
+	mempool = vzalloc(sizeof(struct vxge_hw_mempool));
 	if (mempool == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
 	}
-	memset(mempool, 0, sizeof(struct vxge_hw_mempool));
 
 	mempool->devh			= devh;
 	mempool->memblock_size		= memblock_size;
@@ -1733,31 +1726,27 @@ __vxge_hw_mempool_create(
 
 	/* allocate array of memblocks */
 	mempool->memblocks_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+		vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_arr, 0,
-		sizeof(void *) * mempool->memblocks_max);
 
 	/* allocate array of private parts of items per memblocks */
 	mempool->memblocks_priv_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+		vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_priv_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_priv_arr, 0,
-		    sizeof(void *) * mempool->memblocks_max);
 
 	/* allocate array of memblocks DMA objects */
-	mempool->memblocks_dma_arr = (struct vxge_hw_mempool_dma *)
-		vmalloc(sizeof(struct vxge_hw_mempool_dma) *
+	mempool->memblocks_dma_arr =
+		vzalloc(sizeof(struct vxge_hw_mempool_dma) *
 			mempool->memblocks_max);
 
 	if (mempool->memblocks_dma_arr == NULL) {
@@ -1766,20 +1755,15 @@ __vxge_hw_mempool_create(
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->memblocks_dma_arr, 0,
-			sizeof(struct vxge_hw_mempool_dma) *
-			mempool->memblocks_max);
 
 	/* allocate hash array of items */
-	mempool->items_arr =
-		(void **) vmalloc(sizeof(void *) * mempool->items_max);
+	mempool->items_arr = vzalloc(sizeof(void *) * mempool->items_max);
 	if (mempool->items_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		mempool = NULL;
 		goto exit;
 	}
-	memset(mempool->items_arr, 0, sizeof(void *) * mempool->items_max);
 
 	/* calculate initial number of memblocks */
 	memblocks_to_allocate = (mempool->items_initial +
@@ -4242,15 +4226,12 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 	if (status != VXGE_HW_OK)
 		goto vpath_open_exit1;
 
-	vp = (struct __vxge_hw_vpath_handle *)
-		vmalloc(sizeof(struct __vxge_hw_vpath_handle));
+	vp = vzalloc(sizeof(struct __vxge_hw_vpath_handle));
 	if (vp == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto vpath_open_exit2;
 	}
 
-	memset(vp, 0, sizeof(struct __vxge_hw_vpath_handle));
-
 	vp->vpath = vpath;
 
 	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
-- 
1.7.3.1.g432b3.dirty
