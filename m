From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net 7/8] net: bcmgenet: add begin/complete ethtool ops
Date: Thu,  9 Mar 2017 16:49:05 -0800
Message-ID: <20170310004906.10553-8-opendmb@gmail.com>
References: <20170310004906.10553-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Edwin Chan <edwin.chan@broadcom.com>,
        Doug Berger <doug.berger@broadcom.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310004906.10553-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edwin Chan <edwin.chan@broadcom.com>

Make sure clock is enabled for ethtool ops.

refs #SWLINUX-4311

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Edwin Chan <edwin.chan@broadcom.com>
Signed-off-by: Doug Berger <doug.berger@broadcom.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f93098840775..ec1f3014e410 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -450,6 +450,22 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 			genet_dma_ring_regs[r]);
 }
 
+static int bcmgenet_begin(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	/* Turn on the clock */
+	return clk_prepare_enable(priv->clk);
+}
+
+static void bcmgenet_complete(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+
+	/* Turn off the clock */
+	clk_disable_unprepare(priv->clk);
+}
+
 static int bcmgenet_get_link_ksettings(struct net_device *dev,
 				       struct ethtool_link_ksettings *cmd)
 {
@@ -1022,6 +1038,8 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 
 /* standard ethtool support functions. */
 static const struct ethtool_ops bcmgenet_ethtool_ops = {
+	.begin			= bcmgenet_begin,
+	.complete		= bcmgenet_complete,
 	.get_strings		= bcmgenet_get_strings,
 	.get_sset_count		= bcmgenet_get_sset_count,
 	.get_ethtool_stats	= bcmgenet_get_ethtool_stats,
-- 
2.11.1
