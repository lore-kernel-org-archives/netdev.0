From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 11/11] net/mlx5e: Fix CQ moderation mode not set properly
Date: Thu, 31 Aug 2017 01:21:10 +0300
Message-ID: <20170830222110.15737-12-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Gilboa <talgi@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53278 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751375AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tal Gilboa <talgi@mellanox.com>

cq_period_mode assignment was mistakenly removed so it was always set to "0",
which is EQE based moderation, regardless of the device CAPs and
requested value in ethtool.

Fixes: 6a9764efb255 ("net/mlx5e: Isolate open_channels from priv->params")
Signed-off-by: Tal Gilboa <talgi@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 57f31fa478ce..6ad7f07e7861 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1969,6 +1969,7 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	}
 
 	mlx5e_build_common_cq_param(priv, param);
+	param->cq_period_mode = params->rx_cq_period_mode;
 }
 
 static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
-- 
2.13.0
