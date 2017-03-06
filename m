From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: tundra: tsi108: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  6 Mar 2017 23:26:09 +0100
Message-ID: <1488839169-3813-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, paul.gortmaker@windriver.com,
        jarod@redhat.com, julia.lawall@lip6.fr, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index c558399..5ac6eaa 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1499,27 +1499,29 @@ static void tsi108_init_mac(struct net_device *dev)
 	TSI_WRITE(TSI108_EC_INTMASK, ~0);
 }
 
-static int tsi108_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int tsi108_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
 	unsigned long flags;
 	int rc;
 
 	spin_lock_irqsave(&data->txlock, flags);
-	rc = mii_ethtool_gset(&data->mii_if, cmd);
+	rc = mii_ethtool_get_link_ksettings(&data->mii_if, cmd);
 	spin_unlock_irqrestore(&data->txlock, flags);
 
 	return rc;
 }
 
-static int tsi108_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int tsi108_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
 	unsigned long flags;
 	int rc;
 
 	spin_lock_irqsave(&data->txlock, flags);
-	rc = mii_ethtool_sset(&data->mii_if, cmd);
+	rc = mii_ethtool_set_link_ksettings(&data->mii_if, cmd);
 	spin_unlock_irqrestore(&data->txlock, flags);
 
 	return rc;
@@ -1535,8 +1537,8 @@ static int tsi108_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static const struct ethtool_ops tsi108_ethtool_ops = {
 	.get_link 	= ethtool_op_get_link,
-	.get_settings	= tsi108_get_settings,
-	.set_settings	= tsi108_set_settings,
+	.get_link_ksettings	= tsi108_get_link_ksettings,
+	.set_link_ksettings	= tsi108_set_link_ksettings,
 };
 
 static const struct net_device_ops tsi108_netdev_ops = {
-- 
1.7.4.4
