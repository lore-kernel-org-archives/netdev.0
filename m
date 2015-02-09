From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: [PATCH v2] net: Mellanox: Delete unnecessary checks before the function
 call "vunmap"
Date: Mon, 09 Feb 2015 11:21:26 +0100
Message-ID: <54D88A26.2060307@users.sourceforge.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>	<5317A59D.4@users.sourceforge.net>	<54D22B29.3020200@users.sourceforge.net> <20150205.003404.261962007607296519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150205.003404.261962007607296519.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date: Mon, 9 Feb 2015 11:10:41 +0100

The vunmap() function performs also input parameter validation.
Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Acked-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/alloc.c      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index a716c26..0c51c69 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -662,7 +662,7 @@ void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
 				  buf->direct.buf,
 				  buf->direct.map);
 	else {
-		if (BITS_PER_LONG == 64 && buf->direct.buf)
+		if (BITS_PER_LONG == 64)
 			vunmap(buf->direct.buf);
 
 		for (i = 0; i < buf->nbufs; ++i)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 56779c1..201ca6d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -121,7 +121,7 @@ void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
 		dma_free_coherent(&dev->pdev->dev, buf->size, buf->direct.buf,
 				  buf->direct.map);
 	else {
-		if (BITS_PER_LONG == 64 && buf->direct.buf)
+		if (BITS_PER_LONG == 64)
 			vunmap(buf->direct.buf);
 
 		for (i = 0; i < buf->nbufs; i++)
-- 
2.2.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
