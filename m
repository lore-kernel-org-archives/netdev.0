From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 02/25 v2] mlx4_core: add support for arbitrary bitmap sizes
Date: Fri, 06 Nov 2009 05:08:04 +0200
Message-ID: <4AF39314.5020004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:52446 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759110AbZKFAK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:10:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liran Liss <liranl@mellanox.co.il>

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
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
1.5.3.7




