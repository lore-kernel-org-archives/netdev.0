From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 5/7] mlx4: remove redundant adding of steering type to
 gid
Date: Tue, 14 Feb 2012 18:38:12 +0200
Message-ID: <4F3A8DF4.1050602@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:50546 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757366Ab2BNQky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:40:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

mlx4_uc_steer_add/release() should not add MLX4_UC_STEER flag to gid.
It is added in mlx4_unicast_attach/detach().

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index f44ae55..575839d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -87,7 +87,6 @@ static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 	mac = cpu_to_be64(mac << 16);
 	memcpy(&gid[10], &mac, ETH_ALEN);
 	gid[5] = port;
-	gid[7] = MLX4_UC_STEER << 1;
 
 	err = mlx4_unicast_attach(dev, &qp, gid, 0, MLX4_PROT_ETH);
 	if (err)
@@ -107,7 +106,6 @@ static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
 	mac = cpu_to_be64(mac << 16);
 	memcpy(&gid[10], &mac, ETH_ALEN);
 	gid[5] = port;
-	gid[7] = MLX4_UC_STEER << 1;
 
 	mlx4_unicast_detach(dev, &qp, gid, MLX4_PROT_ETH);
 }
-- 
1.5.4.3
