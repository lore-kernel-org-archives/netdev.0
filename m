From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/13] net/mlx5: Fix E-Switch flow steering capabilities check
Date: Fri, 10 Jun 2016 00:07:33 +0300
Message-ID: <1465506460-1854-7-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34431 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752086AbcFIVId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:33 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add missing capabilities check for E-Switch FDB and ACLs flow
tables before creating their namespace in flow steering.

Fixes: efdc810ba39d ('net/mlx5: Flow steering, Add vport ACL support')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 28 ++++++++++++-----------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index c1efa55..e912a3d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1846,19 +1846,21 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	}
 
 	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
-		err = init_fdb_root_ns(dev);
-		if (err)
-			goto err;
-	}
-	if (MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support)) {
-		err = init_egress_acl_root_ns(dev);
-		if (err)
-			goto err;
-	}
-	if (MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support)) {
-		err = init_ingress_acl_root_ns(dev);
-		if (err)
-			goto err;
+		if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, ft_support)) {
+			err = init_fdb_root_ns(dev);
+			if (err)
+				goto err;
+		}
+		if (MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support)) {
+			err = init_egress_acl_root_ns(dev);
+			if (err)
+				goto err;
+		}
+		if (MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support)) {
+			err = init_ingress_acl_root_ns(dev);
+			if (err)
+				goto err;
+		}
 	}
 
 	return 0;
-- 
2.8.0
