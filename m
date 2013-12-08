From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 11/12] net/mlx4_en: Fix Supported/Advertised link mode reported by ethtool
Date: Sun,  8 Dec 2013 14:35:51 +0200
Message-ID: <1386506152-10298-12-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Rana Shahout <ranas@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40373 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752765Ab3LHMgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:16 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Correctly report the support for 1/10/40Gbps link-speed as
supported/advertised link mode in ethtool's get_settings command.


Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 0596f9f..a601869 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -367,8 +367,28 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int trans_type;
 
 	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = ADVERTISED_10000baseT_Full;
+
+	cmd->supported = SUPPORTED_1000baseT_Full |
+		SUPPORTED_10000baseT_Full |
+		SUPPORTED_1000baseKX_Full |
+		SUPPORTED_10000baseKX4_Full |
+		SUPPORTED_10000baseKR_Full |
+		SUPPORTED_10000baseR_FEC |
+		SUPPORTED_40000baseKR4_Full |
+		SUPPORTED_40000baseCR4_Full |
+		SUPPORTED_40000baseSR4_Full |
+		SUPPORTED_40000baseLR4_Full;
+
+	cmd->advertising = ADVERTISED_1000baseT_Full |
+		ADVERTISED_10000baseT_Full |
+		ADVERTISED_1000baseKX_Full |
+		ADVERTISED_10000baseKX4_Full |
+		ADVERTISED_10000baseKR_Full |
+		ADVERTISED_10000baseR_FEC |
+		ADVERTISED_40000baseKR4_Full |
+		ADVERTISED_40000baseCR4_Full |
+		ADVERTISED_40000baseSR4_Full |
+		ADVERTISED_40000baseLR4_Full;
 
 	if (mlx4_en_QUERY_PORT(priv->mdev, priv->port))
 		return -ENOMEM;
-- 
1.8.3.4
