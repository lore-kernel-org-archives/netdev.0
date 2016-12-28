From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/12] net/mlx5: Check FW limitations on log_max_qp before setting it
Date: Wed, 28 Dec 2016 14:58:32 +0200
Message-ID: <1482929922-32626-3-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Noa Osherovich <noaos@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32802 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751467AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

When setting HCA capabilities, set log_max_qp to be the minimum
between the selected profile's value and the HCA limitation.

Fixes: 938fe83c8dcb ('net/mlx5_core: New device capabilities...')
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 54e5a78..23c12f1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -503,6 +503,13 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	MLX5_SET(cmd_hca_cap, set_hca_cap, pkey_table_size,
 		 to_fw_pkey_sz(dev, 128));
 
+	/* Check log_max_qp from HCA caps to set in current profile */
+	if (MLX5_CAP_GEN_MAX(dev, log_max_qp) < profile[prof_sel].log_max_qp) {
+		mlx5_core_warn(dev, "log_max_qp value in current profile is %d, changing it to HCA capability limit (%d)\n",
+			       profile[prof_sel].log_max_qp,
+			       MLX5_CAP_GEN_MAX(dev, log_max_qp));
+		profile[prof_sel].log_max_qp = MLX5_CAP_GEN_MAX(dev, log_max_qp);
+	}
 	if (prof->mask & MLX5_PROF_MASK_QP_SIZE)
 		MLX5_SET(cmd_hca_cap, set_hca_cap, log_max_qp,
 			 prof->log_max_qp);
-- 
2.7.4
