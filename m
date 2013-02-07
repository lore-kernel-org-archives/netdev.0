From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v2 6/9] net/mlx4_en: Save previous MAC address of the port so we can replace it later
Date: Thu,  7 Feb 2013 14:25:24 +0200
Message-ID: <1360239927-758-7-git-send-email-amirv@mellanox.com>
References: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:47053 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758220Ab3BGMZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 07:25:49 -0500
In-Reply-To: <1360239927-758-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

In preparation to having more than one unicast MAC per port, we need to keep track
of the previous MAC address in the flow of ndo_set_mac_address,
so that mlx4_en_replace_mac will know what to replace.

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 80067d5..72a3fe5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -591,7 +591,7 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 }
 
 static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
-			       unsigned char *new_mac)
+			       unsigned char *new_mac, unsigned char *prev_mac)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_dev *dev = mdev->dev;
@@ -657,7 +657,7 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
 		err = mlx4_en_replace_mac(priv, priv->base_qpn,
-					  priv->dev->dev_addr);
+					  priv->dev->dev_addr, priv->prev_mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 		memcpy(priv->prev_mac, priv->dev->dev_addr,
-- 
1.7.8.2
