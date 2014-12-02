From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCH net-next 2/9] net/mlx5_core: Fix min vectors value in mlx5_enable_msix
Date: Tue,  2 Dec 2014 12:26:12 +0200
Message-ID: <1417515979-22418-3-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417515979-22418-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

mlx5 requires at least one interrupt vector for completions so fix the minvec
argument to pci_enable_msix_range() accordingly.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 4e3c27e77768..c9d4a024f186 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -226,7 +226,7 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 		table->msix_arr[i].entry = i;
 
 	nvec = pci_enable_msix_range(dev->pdev, table->msix_arr,
-				     MLX5_EQ_VEC_COMP_BASE, nvec);
+				     MLX5_EQ_VEC_COMP_BASE + 1, nvec);
 	if (nvec < 0)
 		return nvec;
 
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
