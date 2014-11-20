From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: mlx4: don't duplicate kvfree()
Date: Thu, 20 Nov 2014 08:15:38 +0000
Message-ID: <20141120081538.GJ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 193a6ad..d6f5496 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -130,10 +130,7 @@ static int mlx4_buddy_init(struct mlx4_buddy *buddy, int max_order)
 
 err_out_free:
 	for (i = 0; i <= buddy->max_order; ++i)
-		if (buddy->bits[i] && is_vmalloc_addr(buddy->bits[i]))
-			vfree(buddy->bits[i]);
-		else
-			kfree(buddy->bits[i]);
+		kvfree(buddy->bits[i]);
 
 err_out:
 	kfree(buddy->bits);
@@ -147,10 +144,7 @@ static void mlx4_buddy_cleanup(struct mlx4_buddy *buddy)
 	int i;
 
 	for (i = 0; i <= buddy->max_order; ++i)
-		if (is_vmalloc_addr(buddy->bits[i]))
-			vfree(buddy->bits[i]);
-		else
-			kfree(buddy->bits[i]);
+		kvfree(buddy->bits[i]);
 
 	kfree(buddy->bits);
 	kfree(buddy->num_free);
