From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/12] net/mlx5: Reorder few command cases to reflect their natural order
Date: Wed, 29 Mar 2017 02:27:07 +0300
Message-ID: <20170328232713.29894-7-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42836 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932547AbdC1X2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:01 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Move the commands related to scheduling elements and vport qos to
a suitable location (according to the MLX5_CMD_OP enum values) in
the command string and internal error helpers.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index a380353a78c2..c3c6e931cc35 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -279,6 +279,8 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_DESTROY_XRC_SRQ:
 	case MLX5_CMD_OP_DESTROY_DCT:
 	case MLX5_CMD_OP_DEALLOC_Q_COUNTER:
+	case MLX5_CMD_OP_DESTROY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_DESTROY_QOS_PARA_VPORT:
 	case MLX5_CMD_OP_DEALLOC_PD:
 	case MLX5_CMD_OP_DEALLOC_UAR:
 	case MLX5_CMD_OP_DETACH_FROM_MCG:
@@ -305,8 +307,6 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ROOT:
 	case MLX5_CMD_OP_DEALLOC_ENCAP_HEADER:
-	case MLX5_CMD_OP_DESTROY_SCHEDULING_ELEMENT:
-	case MLX5_CMD_OP_DESTROY_QOS_PARA_VPORT:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -363,6 +363,10 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_Q_COUNTER:
 	case MLX5_CMD_OP_SET_RATE_LIMIT:
 	case MLX5_CMD_OP_QUERY_RATE_LIMIT:
+	case MLX5_CMD_OP_CREATE_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_QUERY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_MODIFY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_CREATE_QOS_PARA_VPORT:
 	case MLX5_CMD_OP_ALLOC_PD:
 	case MLX5_CMD_OP_ALLOC_UAR:
 	case MLX5_CMD_OP_CONFIG_INT_MODERATION:
@@ -414,10 +418,6 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
 	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
 	case MLX5_CMD_OP_ALLOC_ENCAP_HEADER:
-	case MLX5_CMD_OP_CREATE_SCHEDULING_ELEMENT:
-	case MLX5_CMD_OP_QUERY_SCHEDULING_ELEMENT:
-	case MLX5_CMD_OP_MODIFY_SCHEDULING_ELEMENT:
-	case MLX5_CMD_OP_CREATE_QOS_PARA_VPORT:
 		*status = MLX5_DRIVER_STATUS_ABORTED;
 		*synd = MLX5_DRIVER_SYND;
 		return -EIO;
@@ -501,6 +501,12 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(QUERY_Q_COUNTER);
 	MLX5_COMMAND_STR_CASE(SET_RATE_LIMIT);
 	MLX5_COMMAND_STR_CASE(QUERY_RATE_LIMIT);
+	MLX5_COMMAND_STR_CASE(CREATE_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(DESTROY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(QUERY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(MODIFY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(CREATE_QOS_PARA_VPORT);
+	MLX5_COMMAND_STR_CASE(DESTROY_QOS_PARA_VPORT);
 	MLX5_COMMAND_STR_CASE(ALLOC_PD);
 	MLX5_COMMAND_STR_CASE(DEALLOC_PD);
 	MLX5_COMMAND_STR_CASE(ALLOC_UAR);
@@ -576,12 +582,6 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(MODIFY_FLOW_TABLE);
 	MLX5_COMMAND_STR_CASE(ALLOC_ENCAP_HEADER);
 	MLX5_COMMAND_STR_CASE(DEALLOC_ENCAP_HEADER);
-	MLX5_COMMAND_STR_CASE(CREATE_SCHEDULING_ELEMENT);
-	MLX5_COMMAND_STR_CASE(DESTROY_SCHEDULING_ELEMENT);
-	MLX5_COMMAND_STR_CASE(QUERY_SCHEDULING_ELEMENT);
-	MLX5_COMMAND_STR_CASE(MODIFY_SCHEDULING_ELEMENT);
-	MLX5_COMMAND_STR_CASE(CREATE_QOS_PARA_VPORT);
-	MLX5_COMMAND_STR_CASE(DESTROY_QOS_PARA_VPORT);
 	default: return "unknown command opcode";
 	}
 }
-- 
2.11.0
