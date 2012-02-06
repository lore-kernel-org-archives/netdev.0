From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 2/3] mlx4_core: use correct flag for unicast_promisc
Date: Mon, 6 Feb 2012 18:26:29 +0200
Message-ID: <4F2FFF35.3050900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:38823 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754865Ab2BFQjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:39:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Use MLX4_DEV_CAP_FLAG_VEP_UC_STEER for unicast_promisc_add/remove
Unicast entries were managed in wrong data structures.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 0785d9b..00794cb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1004,7 +1004,7 @@ EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_remove);
 
 int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
 		return 0;
 
 	if (mlx4_is_mfunc(dev))
@@ -1016,7 +1016,7 @@ EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_add);
 
 int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
 		return 0;
 
 	if (mlx4_is_mfunc(dev))
-- 
1.5.4.3
