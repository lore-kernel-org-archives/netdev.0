From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 5/6] net/mlx5e: IPoIB, Only support regular RQ for now
Date: Fri, 12 May 2017 14:56:49 +0300
Message-ID: <20170512115650.11635-6-saeedm@mellanox.com>
References: <20170512115650.11635-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51205 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755900AbdELMCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 08:02:03 -0400
In-Reply-To: <20170512115650.11635-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPoIB doesn't support striding RQ at the moment, for this
we need to explicitly choose non striding RQ in IPoIB init,
even if the HW supports it.

Fixes: 8f493ffd88ea ("net/mlx5e: IPoIB, RX steering RSS RQTs and TIRs")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 019c230da498..56bff3540954 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -66,6 +66,10 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 
+	/* Override RQ params as IPoIB supports only LINKED LIST RQ for now */
+	mlx5e_set_rq_type_params(mdev, &priv->channels.params, MLX5_WQ_TYPE_LINKED_LIST);
+	priv->channels.params.lro_en = false;
+
 	mutex_init(&priv->state_lock);
 
 	netdev->hw_features    |= NETIF_F_SG;
-- 
2.11.0
