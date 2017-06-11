From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/6] net/mlx5: Fix create vport flow table flow
Date: Sun, 11 Jun 2017 17:00:23 +0300
Message-ID: <20170611140028.12467-2-saeedm@mellanox.com>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35973 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751953AbdFKOAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:51 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Send vport number to the create flow table inner method instead of
ignoring the vport argument and sending always 0.

Fixes: b3ba51498bdd ('net/mlx5: Refactor create flow table method to accept underlay QP')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 0e487e8ca634..8f5125ccd8d4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -862,7 +862,7 @@ struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace
 	ft_attr.level   = level;
 	ft_attr.prio    = prio;
 
-	return __mlx5_create_flow_table(ns, &ft_attr, FS_FT_OP_MOD_NORMAL, 0);
+	return __mlx5_create_flow_table(ns, &ft_attr, FS_FT_OP_MOD_NORMAL, vport);
 }
 
 struct mlx5_flow_table*
-- 
2.11.0
