From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net] net: eth: altera: Change reset_mac failure message masks from err to dbg
Date: Thu, 12 Feb 2015 10:47:45 -0600
Message-ID: <1423759665-5062-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>
To: <netdev@vger.kernel.org>, <nios2-dev@lists.rocketboards.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This debug output is not really an error message since mac reset can fail
if the phy clocks are gated, specifically when the phy has been placed in
a powered down or isolation mode. The netdev output masks were changed from
err to dbg, and comments added in the code.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 760c72c..996bdf1 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1099,8 +1099,12 @@ static int tse_open(struct net_device *dev)
 
 	spin_lock(&priv->mac_cfg_lock);
 	ret = reset_mac(priv);
+	/* Note that reset_mac will fail if the clocks are gated by the PHY
+	 * due to the PHY being put into isolation or power down mode.
+	 * This is not an error if reset fails due to no clock.
+	 */
 	if (ret)
-		netdev_err(dev, "Cannot reset MAC core (error: %d)\n", ret);
+		netdev_dbg(dev, "Cannot reset MAC core (error: %d)\n", ret);
 
 	ret = init_mac(priv);
 	spin_unlock(&priv->mac_cfg_lock);
@@ -1204,8 +1208,12 @@ static int tse_shutdown(struct net_device *dev)
 	spin_lock(&priv->tx_lock);
 
 	ret = reset_mac(priv);
+	/* Note that reset_mac will fail if the clocks are gated by the PHY
+	 * due to the PHY being put into isolation or power down mode.
+	 * This is not an error if reset fails due to no clock.
+	 */
 	if (ret)
-		netdev_err(dev, "Cannot reset MAC core (error: %d)\n", ret);
+		netdev_dbg(dev, "Cannot reset MAC core (error: %d)\n", ret);
 	priv->dmaops->reset_dma(priv);
 	free_skbufs(dev);
 
-- 
1.9.1
