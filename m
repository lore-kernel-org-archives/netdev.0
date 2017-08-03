From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH] net: arc_emac: Add support for ndo_do_ioctl net_device_ops operation
Date: Thu,  3 Aug 2017 09:49:03 +0200
Message-ID: <20170803074903.19688-1-romain.perier@collabora.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexander Kochetkov <al.kochet@gmail.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Eric Dumazet <edumazet@google.com>,
        Peter Chen <peter.chen@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This operation is required for handling ioctl commands like SIOCGMIIREG,
when debugging MDIO registers from userspace.

This commit adds support for this operation.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
---
 drivers/net/ethernet/arc/emac_main.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 68de2f2652f2..3241af1ce718 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -720,6 +720,18 @@ static int arc_emac_set_address(struct net_device *ndev, void *p)
 	return 0;
 }
 
+static int arc_emac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
+}
+
+
 static const struct net_device_ops arc_emac_netdev_ops = {
 	.ndo_open		= arc_emac_open,
 	.ndo_stop		= arc_emac_stop,
@@ -727,6 +739,7 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 	.ndo_set_mac_address	= arc_emac_set_address,
 	.ndo_get_stats		= arc_emac_stats,
 	.ndo_set_rx_mode	= arc_emac_set_rx_mode,
+	.ndo_do_ioctl		= arc_emac_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= arc_emac_poll_controller,
 #endif
-- 
2.11.0
