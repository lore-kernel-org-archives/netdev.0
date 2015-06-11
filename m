From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx5e: Enforce max flow-tables level >= 3
Date: Thu, 11 Jun 2015 14:47:30 +0300
Message-ID: <1434023253-24362-5-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47286 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752889AbbFKLsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:48:03 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

The Ethernet driver requires at least 3 flow table levels to
operate, enforce that.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3cba6a6..1a655fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1662,7 +1662,10 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	    !MLX5_CAP_ETH(mdev, csum_cap) ||
 	    !MLX5_CAP_ETH(mdev, max_lso_cap) ||
 	    !MLX5_CAP_ETH(mdev, vlan_cap) ||
-	    !MLX5_CAP_ETH(mdev, rss_ind_tbl_cap)) {
+	    !MLX5_CAP_ETH(mdev, rss_ind_tbl_cap) ||
+	    MLX5_CAP_FLOWTABLE(mdev,
+			       flow_table_properties_nic_receive.max_ft_level)
+			       < 3) {
 		mlx5_core_warn(mdev,
 			       "Not creating net device, some required device capabilities are missing\n");
 		return -ENOTSUPP;
-- 
1.7.1
