From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5_core: Remove redundant "err" variable usage
Date: Fri, 25 Sep 2015 10:49:11 +0300
Message-ID: <1443167356-32095-4-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39305 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754792AbbIYHto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:49:44 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Cosmetic change.
Do not use the an err variable just to assign and return it.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 35 ++++++++------------------
 1 file changed, 11 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 821caaa..ae30261 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -90,16 +90,13 @@ int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps)
 {
 	struct mlx5_reg_pcap in;
 	struct mlx5_reg_pcap out;
-	int err;
 
 	memset(&in, 0, sizeof(in));
 	in.caps_127_96 = cpu_to_be32(caps);
 	in.port_num = port_num;
 
-	err = mlx5_core_access_reg(dev, &in, sizeof(in), &out,
-				   sizeof(out), MLX5_REG_PCAP, 0, 1);
-
-	return err;
+	return mlx5_core_access_reg(dev, &in, sizeof(in), &out,
+				    sizeof(out), MLX5_REG_PCAP, 0, 1);
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_caps);
 
@@ -107,16 +104,13 @@ int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 			 int ptys_size, int proto_mask, u8 local_port)
 {
 	u32 in[MLX5_ST_SZ_DW(ptys_reg)];
-	int err;
 
 	memset(in, 0, sizeof(in));
 	MLX5_SET(ptys_reg, in, local_port, local_port);
 	MLX5_SET(ptys_reg, in, proto_mask, proto_mask);
 
-	err = mlx5_core_access_reg(dev, in, sizeof(in), ptys,
-				   ptys_size, MLX5_REG_PTYS, 0, 0);
-
-	return err;
+	return mlx5_core_access_reg(dev, in, sizeof(in), ptys,
+				    ptys_size, MLX5_REG_PTYS, 0, 0);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_ptys);
 
@@ -199,7 +193,6 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 {
 	u32 in[MLX5_ST_SZ_DW(ptys_reg)];
 	u32 out[MLX5_ST_SZ_DW(ptys_reg)];
-	int err;
 
 	memset(in, 0, sizeof(in));
 
@@ -210,9 +203,8 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 	else
 		MLX5_SET(ptys_reg, in, ib_proto_admin, proto_admin);
 
-	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
-				   sizeof(out), MLX5_REG_PTYS, 0, 1);
-	return err;
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_PTYS, 0, 1);
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
 
@@ -250,7 +242,7 @@ int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
 		return err;
 
 	*status = MLX5_GET(paos_reg, out, admin_status);
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_admin_status);
 
@@ -308,15 +300,12 @@ static int mlx5_query_port_pvlc(struct mlx5_core_dev *dev, u32 *pvlc,
 				int pvlc_size,  u8 local_port)
 {
 	u32 in[MLX5_ST_SZ_DW(pvlc_reg)];
-	int err;
 
 	memset(in, 0, sizeof(in));
 	MLX5_SET(ptys_reg, in, local_port, local_port);
 
-	err = mlx5_core_access_reg(dev, in, sizeof(in), pvlc,
-				   pvlc_size, MLX5_REG_PVLC, 0, 0);
-
-	return err;
+	return mlx5_core_access_reg(dev, in, sizeof(in), pvlc,
+				    pvlc_size, MLX5_REG_PVLC, 0, 0);
 }
 
 int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
@@ -339,16 +328,14 @@ int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause)
 {
 	u32 in[MLX5_ST_SZ_DW(pfcc_reg)];
 	u32 out[MLX5_ST_SZ_DW(pfcc_reg)];
-	int err;
 
 	memset(in, 0, sizeof(in));
 	MLX5_SET(pfcc_reg, in, local_port, 1);
 	MLX5_SET(pfcc_reg, in, pptx, tx_pause);
 	MLX5_SET(pfcc_reg, in, pprx, rx_pause);
 
-	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
-				   sizeof(out), MLX5_REG_PFCC, 0, 1);
-	return err;
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_PFCC, 0, 1);
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_pause);
 
-- 
2.3.7
