From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 06/11] net/mlx4_en: Block insertion of ethtool steering rules while the interface is down
Date: Wed, 30 Jan 2013 12:34:22 +0200
Message-ID: <1359542067-10760-7-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:50341 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754216Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Attaching steering rules while the interface is down is an invalid operation, block it.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index f36c219..6f8044d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1006,7 +1006,8 @@ static int mlx4_en_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	if ((cmd->cmd == ETHTOOL_GRXCLSRLCNT ||
 	     cmd->cmd == ETHTOOL_GRXCLSRULE ||
 	     cmd->cmd == ETHTOOL_GRXCLSRLALL) &&
-	    mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED)
+	    (mdev->dev->caps.steering_mode !=
+	     MLX4_STEERING_MODE_DEVICE_MANAGED || !priv->port_up))
 		return -EINVAL;
 
 	switch (cmd->cmd) {
@@ -1042,7 +1043,8 @@ static int mlx4_en_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 
-	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED)
+	if (mdev->dev->caps.steering_mode !=
+	    MLX4_STEERING_MODE_DEVICE_MANAGED || !priv->port_up)
 		return -EINVAL;
 
 	switch (cmd->cmd) {
-- 
1.7.8.2
