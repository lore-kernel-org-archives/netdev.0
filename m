From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] mlx4_en: Use correct loop cursor in error path.
Date: Wed, 29 Apr 2015 15:59:35 -0700
Message-ID: <1430348375-9077-1-git-send-email-bpoirier@suse.de>
Cc: Yuval Atias <yuvala@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Fixes: 9e311e7 ("net/mlx4_en: Use affinity hint")
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0f1afc0..bf173d7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1721,7 +1721,7 @@ mac_err:
 cq_err:
 	while (rx_index--) {
 		mlx4_en_deactivate_cq(priv, priv->rx_cq[rx_index]);
-		mlx4_en_free_affinity_hint(priv, i);
+		mlx4_en_free_affinity_hint(priv, rx_index);
 	}
 	for (i = 0; i < priv->rx_ring_num; i++)
 		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
-- 
2.3.5
