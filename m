From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 15/15] net/mlx5e: Reorder update stats
Date: Fri, 20 Jan 2017 00:39:08 +0200
Message-ID: <20170119223908.15924-16-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59337 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751662AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder update stats flow to update most important counters last,
to get more accurate results.

New update order:
	- PCIe counters
	- Port counters
	- Vport counters
	- Queue counters
	- Software counters

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9aed892cd350..3a06c81ef85e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -321,11 +321,11 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
-	mlx5e_update_q_counter(priv);
-	mlx5e_update_vport_counters(priv);
+	mlx5e_update_pcie_counters(priv);
 	mlx5e_update_pport_counters(priv);
+	mlx5e_update_vport_counters(priv);
+	mlx5e_update_q_counter(priv);
 	mlx5e_update_sw_counters(priv);
-	mlx5e_update_pcie_counters(priv);
 }
 
 void mlx5e_update_stats_work(struct work_struct *work)
-- 
2.11.0
