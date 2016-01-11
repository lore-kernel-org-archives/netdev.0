From: Eugenia Emantayev <eugenia@mellanox.com>
Subject: RE: [PATCH net-next v4 02/10] mlx4: add rtnl lock protection in
 mlx4_en_restart
Date: Mon, 11 Jan 2016 12:12:42 +0000
Message-ID: <DB5PR05MB1765E4F02D810BA5D7C5ED93D1C90@DB5PR05MB1765.eurprd05.prod.outlook.com>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
 <1452352052-27574-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jesse@kernel.org" <jesse@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0077.outbound.protection.outlook.com ([157.55.234.77]:43312
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758693AbcAKM2S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:28:18 -0500
In-Reply-To: <1452352052-27574-3-git-send-email-hannes@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

state_lock is used for internal driver resources synchronization.
Our code will need further examination where rtnl_lock should be used.
For now, thank you for suggestion.
ACK for below patch.

Jenny


-----Original Message-----
From: Hannes Frederic Sowa [mailto:hannes@stressinduktion.org] 
Sent: Saturday, January 09, 2016 17:07
To: netdev@vger.kernel.org
Cc: jesse@kernel.org; Eugenia Emantayev <eugenia@mellanox.com>
Subject: [PATCH net-next v4 02/10] mlx4: add rtnl lock protection in mlx4_en_restart

I don't really understand the use of the state_lock. Can't it be simply replaced by rtnl_lock? It seems a lot of current users depend on rtnl_lock anyway.

Anyway, fix this up for the moment.

Cc: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0c7e3f69a73bb6..94abd0843901cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1846,6 +1846,7 @@ static void mlx4_en_restart(struct work_struct *work)
 
 	en_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
 
+	rtnl_lock();
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		mlx4_en_stop_port(dev, 1);
@@ -1853,6 +1854,7 @@ static void mlx4_en_restart(struct work_struct *work)
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
 	mutex_unlock(&mdev->state_lock);
+	rtnl_unlock();
 }
 
 static void mlx4_en_clear_stats(struct net_device *dev)
