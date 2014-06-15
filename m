From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 11/26] hisilicon: Use dma_zalloc_coherent
Date: Sun, 15 Jun 2014 13:37:40 -0700
Message-ID: <b147291dd4c9fbf6833fb217bd6bd666cfd66446.1402863905.git.joe@perches.com>
References: <cover.1402863904.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1402863904.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the zeroing function instead of dma_alloc_coherent & memset(,0,)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index 0ffdcd3..175b25c 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -867,12 +867,11 @@ static int hix5hd2_init_hw_desc_queue(struct hix5hd2_priv *priv)
 
 	for (i = 0; i < QUEUE_NUMS; i++) {
 		size = priv->pool[i].count * sizeof(struct hix5hd2_desc);
-		virt_addr = dma_alloc_coherent(dev, size, &phys_addr,
-					       GFP_KERNEL);
+		virt_addr = dma_zalloc_coherent(dev, size, &phys_addr,
+						GFP_KERNEL);
 		if (virt_addr == NULL)
 			goto error_free_pool;
 
-		memset(virt_addr, 0, size);
 		priv->pool[i].size = size;
 		priv->pool[i].desc = virt_addr;
 		priv->pool[i].phys_addr = phys_addr;
-- 
1.8.1.2.459.gbcd45b4.dirty
