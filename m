From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/13] net/mlx5: Fix MLX5_CMD_OP_MAX to be defined correctly
Date: Fri, 10 Jun 2016 00:07:30 +0300
Message-ID: <1465506460-1854-4-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Shahar Klein <shahark@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34414 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751455AbcFIVIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:35 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahar Klein <shahark@mellanox.com>

Having MLX5_CMD_OP_MAX on another file causes us to repeatedly miss
accounting new commands added to the driver and hence there're no entries
for them in debugfs. To solve that, we integrate it into the commands enum
as the last entry.

Fixes: 34a40e689393 ('net/mlx5_core: Introduce modify flow table command')
Signed-off-by: Shahar Klein <shahark@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/device.h   | 2 --
 include/linux/mlx5/mlx5_ifc.h | 3 ++-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 035abdf..51f0caf 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1240,8 +1240,6 @@ struct mlx5_destroy_psv_out {
 	u8                      rsvd[8];
 };
 
-#define MLX5_CMD_OP_MAX 0x920
-
 enum {
 	VPORT_STATE_DOWN		= 0x0,
 	VPORT_STATE_UP			= 0x1,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 9a05cd7..986a615 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -205,7 +205,8 @@ enum {
 	MLX5_CMD_OP_ALLOC_FLOW_COUNTER            = 0x939,
 	MLX5_CMD_OP_DEALLOC_FLOW_COUNTER          = 0x93a,
 	MLX5_CMD_OP_QUERY_FLOW_COUNTER            = 0x93b,
-	MLX5_CMD_OP_MODIFY_FLOW_TABLE             = 0x93c
+	MLX5_CMD_OP_MODIFY_FLOW_TABLE             = 0x93c,
+	MLX5_CMD_OP_MAX
 };
 
 struct mlx5_ifc_flow_table_fields_supported_bits {
-- 
2.8.0
