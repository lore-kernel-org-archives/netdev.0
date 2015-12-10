From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 1/9] net/mlx5: Fix query E-Switch capabilities
Date: Thu, 10 Dec 2015 17:12:37 +0200
Message-ID: <1449760365-23622-2-git-send-email-saeedm@mellanox.com>
References: <1449760365-23622-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53733 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754004AbbLJPNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2015 10:13:20 -0500
In-Reply-To: <1449760365-23622-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

E-Switch capabilities should be queried only if E-Switch flow table
is supported and not only when vport group manager.

Fixes: d6666753c6e8 ("net/mlx5: E-Switch, Introduce HCA cap and E-Switch vport context")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 1c9f9a5..aa1ab47 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -173,7 +173,7 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 			return err;
 	}
 
-	if (MLX5_CAP_GEN(dev, vport_group_manager)) {
+	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
 		err = mlx5_core_get_caps(dev, MLX5_CAP_ESWITCH,
 					 HCA_CAP_OPMOD_GET_CUR);
 		if (err)
-- 
1.7.1
