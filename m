From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/4] net/mlx4: Fix typo, move similar defs to same location
Date: Tue, 15 Oct 2013 16:55:22 +0200
Message-ID: <1381848924-18992-3-git-send-email-amirv@mellanox.com>
References: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52153 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933175Ab3JOO4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:56:02 -0400
In-Reply-To: <1381848924-18992-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Small code cleanup:

1. change MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN to MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN

2. put MLX4_SET_PORT_PRIO2TC and MLX4_SET_PORT_SCHEDULER in the same union with the
   other MLX4_SET_PORT_yyy

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        | 2 +-
 include/linux/mlx4/cmd.h                       | 6 ++----
 include/linux/mlx4/device.h                    | 2 +-
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fa37b7a..85d9166 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1733,7 +1733,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	/* Unregister Mac address for the port */
 	mlx4_en_put_qp(priv);
-	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN))
+	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN))
 		mdev->mac_removed[priv->port] = 1;
 
 	/* Free RX Rings */
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 0d63daa..a377484 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -652,7 +652,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FW_REASSIGN_MAC);
 	if (field & 1<<6)
-		dev_cap->flags2 |= MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN;
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN;
 	MLX4_GET(dev_cap->max_icm_sz, outbox,
 		 QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET);
 	if (dev_cap->flags & MLX4_DEV_CAP_FLAG_COUNTERS)
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index cd1fdf7..8df61bc 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -154,10 +154,6 @@ enum {
 	MLX4_CMD_QUERY_IF_STAT	 = 0X54,
 	MLX4_CMD_SET_IF_STAT	 = 0X55,
 
-	/* set port opcode modifiers */
-	MLX4_SET_PORT_PRIO2TC = 0x8,
-	MLX4_SET_PORT_SCHEDULER  = 0x9,
-
 	/* register/delete flow steering network rules */
 	MLX4_QP_FLOW_STEERING_ATTACH = 0x65,
 	MLX4_QP_FLOW_STEERING_DETACH = 0x66,
@@ -182,6 +178,8 @@ enum {
 	MLX4_SET_PORT_VLAN_TABLE = 0x3,
 	MLX4_SET_PORT_PRIO_MAP  = 0x4,
 	MLX4_SET_PORT_GID_TABLE = 0x5,
+	MLX4_SET_PORT_PRIO2TC	= 0x8,
+	MLX4_SET_PORT_SCHEDULER = 0x9,
 };
 
 enum {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 24ce6bd..9ad0c18 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -155,7 +155,7 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RSS_TOP		= 1LL <<  1,
 	MLX4_DEV_CAP_FLAG2_RSS_XOR		= 1LL <<  2,
 	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3,
-	MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN	= 1LL <<  4,
+	MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN	= 1LL <<  4,
 	MLX4_DEV_CAP_FLAG2_TS			= 1LL <<  5,
 	MLX4_DEV_CAP_FLAG2_VLAN_CONTROL		= 1LL <<  6,
 	MLX4_DEV_CAP_FLAG2_FSM			= 1LL <<  7,
-- 
1.8.3.4
