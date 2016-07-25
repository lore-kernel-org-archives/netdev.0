From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 3/5] net/mlx4_en: Preparation for VST QinQ
Date: Mon, 25 Jul 2016 14:15:34 +0300
Message-ID: <1469445336-21952-4-git-send-email-tariqt@mellanox.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36473 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751667AbcGYLQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 07:16:00 -0400
In-Reply-To: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

In Ethernet VF, disable vlan HW acceleration on VF
while the it's set to VST QinQ mode.

Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4198e9bf89d0..3d51bcdd6e8f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3222,6 +3222,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	if (mlx4_is_slave(mdev->dev)) {
+		bool vlan_offload_disabled;
 		int phv;
 
 		err = get_phv_bit(mdev->dev, port, &phv);
@@ -3229,6 +3230,22 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			dev->hw_features |= NETIF_F_HW_VLAN_STAG_TX;
 			priv->pflags |= MLX4_EN_PRIV_FLAGS_PHV;
 		}
+		err = mlx4_get_is_vlan_offload_disabled(mdev->dev, port,
+							&vlan_offload_disabled);
+		if (!err && vlan_offload_disabled) {
+			dev->hw_features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					      NETIF_F_HW_VLAN_CTAG_RX |
+					      NETIF_F_HW_VLAN_CTAG_FILTER |
+					      NETIF_F_HW_VLAN_STAG_FILTER |
+					      NETIF_F_HW_VLAN_STAG_TX |
+					      NETIF_F_HW_VLAN_STAG_RX);
+			dev->features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+					   NETIF_F_HW_VLAN_CTAG_RX |
+					   NETIF_F_HW_VLAN_CTAG_FILTER |
+					   NETIF_F_HW_VLAN_STAG_FILTER |
+					   NETIF_F_HW_VLAN_STAG_TX |
+					   NETIF_F_HW_VLAN_STAG_RX);
+		}
 	} else {
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PHV_EN &&
 		    !(mdev->dev->caps.flags2 &
-- 
1.8.3.1
