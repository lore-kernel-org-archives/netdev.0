From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 4/4] drivers: net: xgene: Add SGMII based 1GbE ethtool support
Date: Mon, 13 Oct 2014 17:05:35 -0700
Message-ID: <1413245135-2989-5-git-send-email-isubramanian@apm.com>
References: <1413245135-2989-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:57995 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754123AbaJNAF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 20:05:59 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so6405572pdj.37
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 17:05:58 -0700 (PDT)
In-Reply-To: <1413245135-2989-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 25 +++++++++++++++-------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index c1c997b..416d6eb 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -64,16 +64,25 @@ static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 			return -ENODEV;
 
 		return phy_ethtool_gset(phydev, cmd);
+	} else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
+		cmd->supported = SUPPORTED_1000baseT_Full |
+				 SUPPORTED_Autoneg | SUPPORTED_MII;
+		cmd->advertising = cmd->supported;
+		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		cmd->duplex = DUPLEX_FULL;
+		cmd->port = PORT_MII;
+		cmd->transceiver = XCVR_INTERNAL;
+		cmd->autoneg = AUTONEG_ENABLE;
+	} else {
+		cmd->supported = SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE;
+		cmd->advertising = cmd->supported;
+		ethtool_cmd_speed_set(cmd, SPEED_10000);
+		cmd->duplex = DUPLEX_FULL;
+		cmd->port = PORT_FIBRE;
+		cmd->transceiver = XCVR_INTERNAL;
+		cmd->autoneg = AUTONEG_DISABLE;
 	}
 
-	cmd->supported = SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE;
-	cmd->advertising = cmd->supported;
-	ethtool_cmd_speed_set(cmd, SPEED_10000);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->port = PORT_FIBRE;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = AUTONEG_DISABLE;
-
 	return 0;
 }
 
-- 
1.9.1
