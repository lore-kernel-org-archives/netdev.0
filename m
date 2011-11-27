From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 3/7] net/mlx4_en: fix sparse warning on a cast which truncates
 bits from constant value
Date: Sun, 27 Nov 2011 07:55:06 +0200
Message-ID: <4ED1D0BA.7050705@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:35292 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753385Ab1K0ITs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

the MLX4_EN_WOL_DO_MODIFY flag which is defined through enum targets
bit 63, this triggers a "cast truncate bits from constant value
(8000000000000000 becomes 0)" warning from sparse, fix that by using
define instead of enum.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6e2657d..c367832 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -484,9 +484,9 @@ struct mlx4_en_priv {
 enum mlx4_en_wol {
 	MLX4_EN_WOL_MAGIC = (1ULL << 61),
 	MLX4_EN_WOL_ENABLED = (1ULL << 62),
-	MLX4_EN_WOL_DO_MODIFY = (1ULL << 63),
 };
 
+#define MLX4_EN_WOL_DO_MODIFY (1ULL << 63)
 
 void mlx4_en_destroy_netdev(struct net_device *dev);
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
-- 
1.7.7
