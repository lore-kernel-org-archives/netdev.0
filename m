From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch v2] mlx5_core: delete some dead code
Date: Tue, 5 Nov 2013 01:20:56 +0300
Message-ID: <20131104222056.GA4248@elgon.mountain>
References: <20131103070326.GA3051@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131103070326.GA3051@mtldesk30>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The printk() looks like it is left over debug code.  I have removed it.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
v2:  Remove the printk instead of moving it infront of the return.

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index ba816c2..9b79067 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -192,10 +192,8 @@ static int alloc_4k(struct mlx5_core_dev *dev, u64 *addr)
 	struct fw_page *fp;
 	unsigned n;
 
-	if (list_empty(&dev->priv.free_list)) {
+	if (list_empty(&dev->priv.free_list))
 		return -ENOMEM;
-		mlx5_core_warn(dev, "\n");
-	}
 
 	fp = list_entry(dev->priv.free_list.next, struct fw_page, list);
 	n = find_first_bit(&fp->bitmask, 8 * sizeof(fp->bitmask));
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
