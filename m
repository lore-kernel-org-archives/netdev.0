From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/6] net/mlx5: Enable 4K UAR only when page size is bigger than 4K
Date: Sun, 11 Jun 2017 17:00:28 +0300
Message-ID: <20170611140028.12467-7-saeedm@mellanox.com>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35968 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751946AbdFKOAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:51 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

When the page size isn't bigger than 4K, there is no added value of enabling 4K
UAR feature in the Firmware.

Modified the condition of enabling the 4K UAR accordingly.

Fixes: f502d834950a ("net/mlx5: Activate support for 4K UARs")
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index af945edfee19..4f577a5abf88 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -537,8 +537,10 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	/* disable cmdif checksum */
 	MLX5_SET(cmd_hca_cap, set_hca_cap, cmdif_checksum, 0);
 
-	/* If the HCA supports 4K UARs use it */
-	if (MLX5_CAP_GEN_MAX(dev, uar_4k))
+	/* Enable 4K UAR only when HCA supports it and page size is bigger
+	 * than 4K.
+	 */
+	if (MLX5_CAP_GEN_MAX(dev, uar_4k) && PAGE_SIZE > 4096)
 		MLX5_SET(cmd_hca_cap, set_hca_cap, uar_4k, 1);
 
 	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
-- 
2.11.0
