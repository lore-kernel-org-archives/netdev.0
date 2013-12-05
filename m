From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] mlx4_en: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:54:50 +0000
Message-ID: <1386287690.1516.138.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6711 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268Ab3LEXyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:54:54 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e72d8a112a6b..709e5ec5ce14 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2025,7 +2025,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int mlx4_en_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
+static int mlx4_en_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -2084,11 +2084,21 @@ static int mlx4_en_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			    sizeof(config)) ? -EFAULT : 0;
 }
 
+static int mlx4_en_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return copy_to_user(ifr->ifr_data, &priv->hwtstamp_config,
+			    sizeof(priv->hwtstamp_config)) ? -EFAULT : 0;
+}
+
 static int mlx4_en_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return mlx4_en_hwtstamp_ioctl(dev, ifr);
+		return mlx4_en_hwtstamp_set(dev, ifr);
+	case SIOCGHWTSTAMP:
+		return mlx4_en_hwtstamp_get(dev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}

		
-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
