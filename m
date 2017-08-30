From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 03/11] net/mlx5: Fix arm SRQ command for ISSI version 0
Date: Thu, 31 Aug 2017 01:21:02 +0300
Message-ID: <20170830222110.15737-4-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Noa Osherovich <noaos@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53228 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751286AbdH3WVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:32 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

Support for ISSI version 0 was recently broken as the arm_srq_cmd
command, which is used only for ISSI version 0, was given the opcode
for ISSI version 1 instead of ISSI version 0.

Change arm_srq_cmd to use the correct command opcode for ISSI version
0.

Fixes: af1ba291c5e4 ('{net, IB}/mlx5: Refactor internal SRQ API')
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/srq.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
index f774de6f5fcb..520f6382dfde 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/srq.c
@@ -201,13 +201,13 @@ static int destroy_srq_cmd(struct mlx5_core_dev *dev,
 static int arm_srq_cmd(struct mlx5_core_dev *dev, struct mlx5_core_srq *srq,
 		       u16 lwm, int is_srq)
 {
-	/* arm_srq structs missing using identical xrc ones */
-	u32 srq_in[MLX5_ST_SZ_DW(arm_xrc_srq_in)] = {0};
-	u32 srq_out[MLX5_ST_SZ_DW(arm_xrc_srq_out)] = {0};
+	u32 srq_in[MLX5_ST_SZ_DW(arm_rq_in)] = {0};
+	u32 srq_out[MLX5_ST_SZ_DW(arm_rq_out)] = {0};
 
-	MLX5_SET(arm_xrc_srq_in, srq_in, opcode,   MLX5_CMD_OP_ARM_XRC_SRQ);
-	MLX5_SET(arm_xrc_srq_in, srq_in, xrc_srqn, srq->srqn);
-	MLX5_SET(arm_xrc_srq_in, srq_in, lwm,      lwm);
+	MLX5_SET(arm_rq_in, srq_in, opcode, MLX5_CMD_OP_ARM_RQ);
+	MLX5_SET(arm_rq_in, srq_in, op_mod, MLX5_ARM_RQ_IN_OP_MOD_SRQ);
+	MLX5_SET(arm_rq_in, srq_in, srq_number, srq->srqn);
+	MLX5_SET(arm_rq_in, srq_in, lwm,      lwm);
 
 	return  mlx5_cmd_exec(dev, srq_in, sizeof(srq_in),
 			      srq_out, sizeof(srq_out));
-- 
2.13.0
