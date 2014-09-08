From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] net/mlx4_en: do not ignore autoneg in mlx4_en_set_pauseparam()
Date: Mon,  8 Sep 2014 18:46:53 +0200
Message-ID: <1410194813-994-1-git-send-email-ivecera@redhat.com>
Cc: Amir Vadai <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754071AbaIHQqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 12:46:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not support pause autonegotiation so it should return
-EINVAL when the function is called with non-zero autoneg.

Cc: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index e22f24f..35ff292 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -487,6 +487,9 @@ static int mlx4_en_set_pauseparam(struct net_device *dev,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
 
+	if (pause->autoneg)
+		return -EINVAL;
+
 	priv->prof->tx_pause = pause->tx_pause != 0;
 	priv->prof->rx_pause = pause->rx_pause != 0;
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
-- 
1.8.5.5
