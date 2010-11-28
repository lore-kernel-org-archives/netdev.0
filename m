From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] vxge: remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 01:05:45 -0800
Message-ID: <74d8a4012e9c912fbfeb8f9fcf304c0a41931f2e.1290934782.git.joe@perches.com>
References: <cover.1290934782.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1889 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001Ab0K1JFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 04:05:53 -0500
In-Reply-To: <cover.1290934782.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vxge/vxge-config.c |   24 +++++++++---------------
 drivers/net/vxge/vxge-main.c   |    4 +---
 2 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 44d3ddd..a0241fe 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -1219,8 +1219,7 @@ vxge_hw_device_initialize(
 	if (status != VXGE_HW_OK)
 		goto exit;
 
-	hldev = (struct __vxge_hw_device *)
-			vzalloc(sizeof(struct __vxge_hw_device));
+	hldev = vzalloc(sizeof(struct __vxge_hw_device));
 	if (hldev == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
@@ -2140,8 +2139,7 @@ __vxge_hw_mempool_create(
 		goto exit;
 	}
 
-	mempool = (struct vxge_hw_mempool *)
-			vzalloc(sizeof(struct vxge_hw_mempool));
+	mempool = vzalloc(sizeof(struct vxge_hw_mempool));
 	if (mempool == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto exit;
@@ -2165,7 +2163,7 @@ __vxge_hw_mempool_create(
 
 	/* allocate array of memblocks */
 	mempool->memblocks_arr =
-		(void **) vzalloc(sizeof(void *) * mempool->memblocks_max);
+		vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
@@ -2175,7 +2173,7 @@ __vxge_hw_mempool_create(
 
 	/* allocate array of private parts of items per memblocks */
 	mempool->memblocks_priv_arr =
-		(void **) vzalloc(sizeof(void *) * mempool->memblocks_max);
+		vzalloc(sizeof(void *) * mempool->memblocks_max);
 	if (mempool->memblocks_priv_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
@@ -2184,7 +2182,7 @@ __vxge_hw_mempool_create(
 	}
 
 	/* allocate array of memblocks DMA objects */
-	mempool->memblocks_dma_arr = (struct vxge_hw_mempool_dma *)
+	mempool->memblocks_dma_arr =
 		vzalloc(sizeof(struct vxge_hw_mempool_dma) *
 			mempool->memblocks_max);
 
@@ -2196,8 +2194,7 @@ __vxge_hw_mempool_create(
 	}
 
 	/* allocate hash array of items */
-	mempool->items_arr =
-		(void **) vzalloc(sizeof(void *) * mempool->items_max);
+	mempool->items_arr = vzalloc(sizeof(void *) * mempool->items_max);
 	if (mempool->items_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
@@ -4258,8 +4255,7 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 	if (status != VXGE_HW_OK)
 		goto vpath_open_exit1;
 
-	vp = (struct __vxge_hw_vpath_handle *)
-		vzalloc(sizeof(struct __vxge_hw_vpath_handle));
+	vp = vzalloc(sizeof(struct __vxge_hw_vpath_handle));
 	if (vp == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto vpath_open_exit2;
@@ -5065,8 +5061,7 @@ static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
 				item);
 
 	if (entry == NULL)
-		entry = (struct __vxge_hw_blockpool_entry *)
-			vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
+		entry = vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
 	else
 		list_del(&entry->item);
 
@@ -5182,8 +5177,7 @@ __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
 					item);
 
 		if (entry == NULL)
-			entry = (struct __vxge_hw_blockpool_entry *)
-				vmalloc(sizeof(
+			entry = vmalloc(sizeof(
 					struct __vxge_hw_blockpool_entry));
 		else
 			list_del(&entry->item);
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 5cba4a6..a21dae1 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4602,9 +4602,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	/* Copy the station mac address to the list */
 	for (i = 0; i < vdev->no_of_vpath; i++) {
-		entry =	(struct vxge_mac_addrs *)
-				kzalloc(sizeof(struct vxge_mac_addrs),
-					GFP_KERNEL);
+		entry =	kzalloc(sizeof(struct vxge_mac_addrs), GFP_KERNEL);
 		if (NULL == entry) {
 			vxge_debug_init(VXGE_ERR,
 				"%s: mac_addr_list : memory allocation failed",
-- 
1.7.3.2.245.g03276.dirty

