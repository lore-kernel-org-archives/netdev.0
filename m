From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 02/25] mlx4_core: add support for arbitrary bitmap sizes
Date: Wed, 04 Nov 2009 17:30:21 +0200
Message-ID: <4AF19E0D.1030504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/alloc.c |   10 ++++++++++
 drivers/net/mlx4/mlx4.h  |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index ad95d5f..bc68cc3 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -177,6 +177,16 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	return 0;
 }
 
+/* Like bitmap_init, but doesn't require 'num' to be a power of 2 or
+ * a non-trivial mask */
+int mlx4_bitmap_init_no_mask(struct mlx4_bitmap *bitmap, u32 num,
+			     u32 reserved_bot, u32 reserved_top)
+{
+	u32 num_rounded = roundup_pow_of_two(num);
+	return mlx4_bitmap_init(bitmap, num_rounded, num_rounded - 1,
+				reserved_bot, num_rounded - num + reserved_top);
+}
+
 void mlx4_bitmap_cleanup(struct mlx4_bitmap *bitmap)
 {
 	kfree(bitmap->table);
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index bc72d6e..5836c94 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -330,6 +330,8 @@ u32 mlx4_bitmap_alloc_range(struct mlx4_bitmap *bitmap, int cnt, int align);
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt);
 int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 		     u32 reserved_bot, u32 resetrved_top);
+int mlx4_bitmap_init_no_mask(struct mlx4_bitmap *bitmap, u32 num,
+			     u32 reserved_bot, u32 reserved_top);
 void mlx4_bitmap_cleanup(struct mlx4_bitmap *bitmap);
 
 int mlx4_reset(struct mlx4_dev *dev);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
