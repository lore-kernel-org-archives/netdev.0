From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 01/13] net/mlx5: Fix teardown errors that happen in pci error handler
Date: Thu, 30 Jun 2016 17:34:38 +0300
Message-ID: <1467297290-11443-2-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37671 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751997AbcF3OhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:21 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

In case of internal error state we will simulate the commands status
through the return value translation function, but we need to simulate
all the teardown fw commands as successful so we will not have fw
command failure prints.
This also fix memory leaks that happen because we skip teardown stages
due to failed fw commands.

Fixes: 89d44f0a6c73 ('net/mlx5_core: Add pci error handlers to mlx5_core driver')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 0b49862..fda43bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -295,6 +295,12 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_DESTROY_FLOW_GROUP:
 	case MLX5_CMD_OP_DELETE_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_DEALLOC_FLOW_COUNTER:
+	case MLX5_CMD_OP_2ERR_QP:
+	case MLX5_CMD_OP_2RST_QP:
+	case MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT:
+	case MLX5_CMD_OP_MODIFY_FLOW_TABLE:
+	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
+	case MLX5_CMD_OP_SET_FLOW_TABLE_ROOT:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -321,8 +327,6 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_RTR2RTS_QP:
 	case MLX5_CMD_OP_RTS2RTS_QP:
 	case MLX5_CMD_OP_SQERR2RTS_QP:
-	case MLX5_CMD_OP_2ERR_QP:
-	case MLX5_CMD_OP_2RST_QP:
 	case MLX5_CMD_OP_QUERY_QP:
 	case MLX5_CMD_OP_SQD_RTS_QP:
 	case MLX5_CMD_OP_INIT2INIT_QP:
@@ -342,7 +346,6 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_ESW_VPORT_CONTEXT:
 	case MLX5_CMD_OP_MODIFY_ESW_VPORT_CONTEXT:
 	case MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT:
-	case MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT:
 	case MLX5_CMD_OP_QUERY_ROCE_ADDRESS:
 	case MLX5_CMD_OP_SET_ROCE_ADDRESS:
 	case MLX5_CMD_OP_QUERY_HCA_VPORT_CONTEXT:
@@ -390,11 +393,12 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_CREATE_RQT:
 	case MLX5_CMD_OP_MODIFY_RQT:
 	case MLX5_CMD_OP_QUERY_RQT:
+
 	case MLX5_CMD_OP_CREATE_FLOW_TABLE:
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE:
 	case MLX5_CMD_OP_CREATE_FLOW_GROUP:
 	case MLX5_CMD_OP_QUERY_FLOW_GROUP:
-	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
+
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
 	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
-- 
2.8.0
