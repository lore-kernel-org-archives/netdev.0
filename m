From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: [PATCH 1/1] Fixed to BUG_ON to WARN_ON def
Date: Mon, 12 Dec 2016 12:58:59 +0200
Message-ID: <811031481540339@web1j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: yishaih@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all, 
I think should be use to "WARN_ON" and checkpatch script give to error, I fixed and I think  should don't use "BUG_ON".
Regards,

Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
---
drivers/net/ethernet/mellanox/mlx4/icm.c |  4 ++--

diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 2a9dd46..3fde535 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -119,7 +119,7 @@ static int mlx4_alloc_icm_coherent(struct device *dev, struct scatterlist *mem,
 		return -ENOMEM;
 
 	sg_set_buf(mem, buf, PAGE_SIZE << order);
-	BUG_ON(mem->offset);
+	WARN_ON(mem->offset);
 	sg_dma_len(mem) = PAGE_SIZE << order;
 	return 0;
 }
@@ -133,7 +133,7 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 	int ret;
 
 	/* We use sg_set_buf for coherent allocs, which assumes low memory */
-	BUG_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
+	WARN_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
 
 	icm = kmalloc_node(sizeof(*icm),
 			   gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN),
-- 
2.1.4
