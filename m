From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ibmveth: consolidate kmalloc of array, memset 0 to kcalloc
Date: Sun, 20 Dec 2015 15:06:18 +0100
Message-ID: <1450620378-8342-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:46392 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932558AbbLTOKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2015 09:10:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an API consolidation only. The use of kmalloc + memset to 0
is equivalent to kcalloc in this case as it is allocating an array
of elements.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Found by coccinelle script (relaxed version of
scripts/coccinelle/api/alloc/kzalloc-simple.cocci)

Patch was compile tested with: ppc64_defconfig
(implies CONFIG_IBMVETH=m)

Patch is against linux-next (localversion-next is -next-20150518)

 drivers/net/ethernet/ibm/ibmveth.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 6691b5a..05f5e81 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -169,7 +169,7 @@ static int ibmveth_alloc_buffer_pool(struct ibmveth_buff_pool *pool)
 	if (!pool->free_map)
 		return -1;
 
-	pool->dma_addr = kmalloc(sizeof(dma_addr_t) * pool->size, GFP_KERNEL);
+	pool->dma_addr = kcalloc(pool->size, sizeof(dma_addr_t), GFP_KERNEL);
 	if (!pool->dma_addr) {
 		kfree(pool->free_map);
 		pool->free_map = NULL;
@@ -187,8 +187,6 @@ static int ibmveth_alloc_buffer_pool(struct ibmveth_buff_pool *pool)
 		return -1;
 	}
 
-	memset(pool->dma_addr, 0, sizeof(dma_addr_t) * pool->size);
-
 	for (i = 0; i < pool->size; ++i)
 		pool->free_map[i] = i;
 
-- 
1.7.10.4
