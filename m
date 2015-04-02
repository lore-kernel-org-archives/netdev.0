From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 03/18] net/mlx4: Make mlx4_is_eth visible inline funcion
Date: Thu,  2 Apr 2015 16:31:08 +0300
Message-ID: <1427981483-19317-4-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45656 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752641AbbDBNbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:51 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Currently implemented as static function in resource_tracker.c --
this change will allow other files in mlx4_core to use it as well.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    5 -----
 include/linux/mlx4/device.h                        |    5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c258f86..2076e98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -221,11 +221,6 @@ struct res_fs_rule {
 	int			qpn;
 };
 
-static int mlx4_is_eth(struct mlx4_dev *dev, int port)
-{
-	return dev->caps.port_mask[port] == MLX4_PORT_TYPE_IB ? 0 : 1;
-}
-
 static void *res_tracker_lookup(struct rb_root *root, u64 res_id)
 {
 	struct rb_node *node = root->rb_node;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 41eaafd..0f7f13d 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1002,6 +1002,11 @@ static inline int mlx4_is_slave(struct mlx4_dev *dev)
 	return dev->flags & MLX4_FLAG_SLAVE;
 }
 
+static inline int mlx4_is_eth(struct mlx4_dev *dev, int port)
+{
+	return dev->caps.port_type[port] == MLX4_PORT_TYPE_IB ? 0 : 1;
+}
+
 int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		   struct mlx4_buf *buf, gfp_t gfp);
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
-- 
1.7.1
