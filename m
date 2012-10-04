From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH 02/11] net: axienet: Add ioctl support
Date: Thu,  4 Oct 2012 20:14:48 +0200
Message-ID: <1349374497-9540-2-git-send-email-monstr@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow user to access the MDIO from userspace.

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Anirudha Sarangi <anirudh@xilinx.com>
CC: John Linn <John.Linn@xilinx.com>
CC: Grant Likely <grant.likely@secretlab.ca>
CC: Rob Herring <rob.herring@calxeda.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 50167ab..a5b41cd 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1053,6 +1053,20 @@ static void axienet_poll_controller(struct net_device *ndev)
 }
 #endif
 
+/* Ioctl MII Interface */
+static int axienet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct axienet_local *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!priv->phy_dev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(priv->phy_dev, rq, cmd);
+}
+
 static const struct net_device_ops axienet_netdev_ops = {
 	.ndo_open = axienet_open,
 	.ndo_stop = axienet_stop,
@@ -1061,6 +1075,7 @@ static const struct net_device_ops axienet_netdev_ops = {
 	.ndo_set_mac_address = netdev_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_set_rx_mode = axienet_set_multicast_list,
+	.ndo_do_ioctl = axienet_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = axienet_poll_controller,
 #endif
-- 
1.7.0.4
