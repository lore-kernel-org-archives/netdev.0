From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch -next] mlx5_core: warn if no space left in alloc_4k()
Date: Fri, 1 Nov 2013 13:20:44 +0300
Message-ID: <20131101102044.GB29795@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The warning was unreachable.  In the original code, it would print the
line number and the function but I have added an error message.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
I haven't tested this, hopefully the warning is not annoying.

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index ba816c2..cb86265 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -193,8 +193,8 @@ static int alloc_4k(struct mlx5_core_dev *dev, u64 *addr)
 	unsigned n;
 
 	if (list_empty(&dev->priv.free_list)) {
+		mlx5_core_warn(dev, "no available space\n");
 		return -ENOMEM;
-		mlx5_core_warn(dev, "\n");
 	}
 
 	fp = list_entry(dev->priv.free_list.next, struct fw_page, list);
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
