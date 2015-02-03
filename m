From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx4_en: Notify TX Vlan offload change
Date: Tue,  3 Feb 2015 17:57:21 +0200
Message-ID: <1422979041-25208-8-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40334 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966308AbbBCP6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:43 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Notify users when TX vlan offload feature changed with ethtool.
Relevant command - ethtool -K <eth> txvlan on/off.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e075ff1..0897274 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2201,6 +2201,10 @@ static int mlx4_en_set_features(struct net_device *netdev,
 			return ret;
 	}
 
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_CTAG_TX))
+		en_info(priv, "Turn %s TX vlan strip offload\n",
+			(features & NETIF_F_HW_VLAN_CTAG_TX) ? "ON" : "OFF");
+
 	if (features & NETIF_F_LOOPBACK)
 		priv->ctrl_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
 	else
-- 
1.9.3
