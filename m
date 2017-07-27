From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 06/14] net/mlx5e: Fix outer_header_zero() check size
Date: Thu, 27 Jul 2017 16:56:09 +0300
Message-ID: <20170727135617.18559-7-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40090 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751446AbdG0N5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:15 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

outer_header_zero() routine checks if the outer_headers match of a
flow-table entry are all zero.

This function uses the size of whole fte_match_param, instead of just
the outer_headers member, causing failure to detect all-zeros if
any other members of the fte_match_param are non-zero.

Use the correct size for zero check.

Fixes: 6dc6071cfcde ("net/mlx5e: Add ethtool flow steering support")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index bdd82c9b3992..22fb993987b4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -276,7 +276,7 @@ static void add_rule_to_list(struct mlx5e_priv *priv,
 
 static bool outer_header_zero(u32 *match_criteria)
 {
-	int size = MLX5_ST_SZ_BYTES(fte_match_param);
+	int size = MLX5_FLD_SZ_BYTES(fte_match_param, outer_headers);
 	char *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_criteria,
 					     outer_headers);
 
-- 
2.13.0
