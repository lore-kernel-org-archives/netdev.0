From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Removing HW info from ethtool -i report.
Date: Thu, 24 Mar 2011 10:36:27 +0200
Message-ID: <4D8B028B.8050406@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:54778 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933713Ab1CXIga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 04:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoiding abuse of ethtool_drvinfo.driver field.
HW specific info can be retrieved using lspci.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 62ace6c..d54b7ab 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -45,20 +45,7 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 
-	switch (mdev->dev->rev_id) {
-	case 0xa0:
-		if (dev->dev_id >= MLX4_EN_CX3_LOW_ID && dev->dev_id <= MLX4_EN_CX3_HIGH_ID)
-			sprintf(drvinfo->driver, DRV_NAME " (%s_CX-3)", mdev->dev->board_id);
-		else
-			sprintf(drvinfo->driver, DRV_NAME " (%s_CX)", mdev->dev->board_id);
-		break;
-	case 0xb0:
-		sprintf(drvinfo->driver, DRV_NAME " (%s_CX-2)", mdev->dev->board_id);
-		break;
-	default:
-		sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
-		break;
-	}
+	strncpy(drvinfo->driver, DRV_NAME, 32);
 	strncpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")", 32);
 	sprintf(drvinfo->fw_version, "%d.%d.%d",
 		(u16) (mdev->dev->caps.fw_ver >> 32),
-- 
1.6.0.2



