From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/7] net/mlx5e: Change enum to better reflect usage
Date: Mon, 27 Jun 2016 12:08:34 +0300
Message-ID: <1467018518-11630-4-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53267 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750870AbcF0JQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:30 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Change MLX5E_STATE_ASYNC_EVENTS_ENABLE to
MLX5E_STATE_ASYNC_EVENTS_ENABLED since it represent a state and not an
operation.

Fixes: acff797cd1874 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e8a6c33..baa991a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -401,7 +401,7 @@ enum mlx5e_traffic_types {
 };
 
 enum {
-	MLX5E_STATE_ASYNC_EVENTS_ENABLE,
+	MLX5E_STATE_ASYNC_EVENTS_ENABLED,
 	MLX5E_STATE_OPENED,
 	MLX5E_STATE_DESTROYING,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f5c8d5d..4383f8c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -244,7 +244,7 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 {
 	struct mlx5e_priv *priv = vpriv;
 
-	if (!test_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state))
+	if (!test_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLED, &priv->state))
 		return;
 
 	switch (event) {
@@ -260,12 +260,12 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 
 static void mlx5e_enable_async_events(struct mlx5e_priv *priv)
 {
-	set_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state);
+	set_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLED, &priv->state);
 }
 
 static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
 {
-	clear_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state);
+	clear_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLED, &priv->state);
 	synchronize_irq(mlx5_get_msix_vec(priv->mdev, MLX5_EQ_VEC_ASYNC));
 }
 
-- 
2.8.0
