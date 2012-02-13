From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] mlx4: Fix kcalloc parameters swapped
Date: Mon, 13 Feb 2012 09:14:39 +0800
Message-ID: <1329095679.3066.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first parameter should be "number of elements" and the second parameter
should be "element size".

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 55d7bd4..8fa41f3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -815,8 +815,9 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 	int err;
 	int i;
 
-	priv->eq_table.uar_map = kcalloc(sizeof *priv->eq_table.uar_map,
-					 mlx4_num_eq_uar(dev), GFP_KERNEL);
+	priv->eq_table.uar_map = kcalloc(mlx4_num_eq_uar(dev),
+					 sizeof *priv->eq_table.uar_map,
+					 GFP_KERNEL);
 	if (!priv->eq_table.uar_map) {
 		err = -ENOMEM;
 		goto err_out_free;
-- 
1.7.5.4
