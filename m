From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: via: via-rhine: use new api ethtool_{get|set}_link_ksettings
Date: Tue,  7 Mar 2017 23:46:16 +0100
Message-ID: <1488926776-11073-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com, stephen@networkplumber.org,
        edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/via/via-rhine.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index c068c58..4cf41f7 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2303,25 +2303,27 @@ static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 	strlcpy(info->bus_info, dev_name(hwdev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
 	mutex_lock(&rp->task_lock);
-	rc = mii_ethtool_gset(&rp->mii_if, cmd);
+	rc = mii_ethtool_get_link_ksettings(&rp->mii_if, cmd);
 	mutex_unlock(&rp->task_lock);
 
 	return rc;
 }
 
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netdev_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
 	mutex_lock(&rp->task_lock);
-	rc = mii_ethtool_sset(&rp->mii_if, cmd);
+	rc = mii_ethtool_set_link_ksettings(&rp->mii_if, cmd);
 	rhine_set_carrier(&rp->mii_if);
 	mutex_unlock(&rp->task_lock);
 
@@ -2391,14 +2393,14 @@ static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
 	.get_wol		= rhine_get_wol,
 	.set_wol		= rhine_set_wol,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
