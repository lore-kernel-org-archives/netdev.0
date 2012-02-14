From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 6/7] mlx4: attach multicast with correct flag
Date: Tue, 14 Feb 2012 18:38:33 +0200
Message-ID: <4F3A8E09.2040605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:35532 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757834Ab2BNQmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:42:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

mlx4_multicast_attach/detach() should use always MLX4_MC_STEER flag

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index da63874..4799e82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -870,44 +870,36 @@ static int mlx4_QP_ATTACH(struct mlx4_dev *dev, struct mlx4_qp *qp,
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot)
 {
-	enum mlx4_steer_type steer;
-
-	steer = (is_valid_ether_addr(&gid[10])) ? MLX4_UC_STEER : MLX4_MC_STEER;
-
 	if (prot == MLX4_PROT_ETH &&
 			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
 	if (prot == MLX4_PROT_ETH)
-		gid[7] |= (steer << 1);
+		gid[7] |= (MLX4_MC_STEER << 1);
 
 	if (mlx4_is_mfunc(dev))
 		return mlx4_QP_ATTACH(dev, qp, gid, 1,
 					block_mcast_loopback, prot);
 
 	return mlx4_qp_attach_common(dev, qp, gid, block_mcast_loopback,
-					prot, steer);
+					prot, MLX4_MC_STEER);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  enum mlx4_protocol prot)
 {
-	enum mlx4_steer_type steer;
-
-	steer = (is_valid_ether_addr(&gid[10])) ? MLX4_UC_STEER : MLX4_MC_STEER;
-
 	if (prot == MLX4_PROT_ETH &&
 			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
 		return 0;
 
 	if (prot == MLX4_PROT_ETH)
-		gid[7] |= (steer << 1);
+		gid[7] |= (MLX4_MC_STEER << 1);
 
 	if (mlx4_is_mfunc(dev))
 		return mlx4_QP_ATTACH(dev, qp, gid, 0, 0, prot);
 
-	return mlx4_qp_detach_common(dev, qp, gid, prot, steer);
+	return mlx4_qp_detach_common(dev, qp, gid, prot, MLX4_MC_STEER);
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
-- 
1.5.4.3
