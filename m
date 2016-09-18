From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: mvneta: mark symbols static where possible
Date: Sun, 18 Sep 2016 17:20:45 +0800
Message-ID: <1474190445-5887-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36391 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755076AbcIRJU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 05:20:58 -0400
Received: by mail-pa0-f47.google.com with SMTP id id6so39029208pad.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 02:20:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/marvell/mvneta.c:639:27: warning: no previous prototype for 'mvneta_get_stats64' [-Wmissing-prototypes]
drivers/net/ethernet/marvell/mvneta.c:3529:5: warning: no previous prototype for 'mvneta_ethtool_set_link_ksettings' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/marvell/mvneta.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 32f0cc4..03be592 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -636,8 +636,9 @@ static void mvneta_mib_counters_clear(struct mvneta_port *pp)
 }
 
 /* Get System Network Statistics */
-struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
-					     struct rtnl_link_stats64 *stats)
+static struct
+rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
+				      struct rtnl_link_stats64 *stats)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
 	unsigned int start;
@@ -3526,8 +3527,9 @@ static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 /* Ethtool methods */
 
 /* Set link ksettings (phy address, speed) for ethtools */
-int mvneta_ethtool_set_link_ksettings(struct net_device *ndev,
-				      const struct ethtool_link_ksettings *cmd)
+static int
+mvneta_ethtool_set_link_ksettings(struct net_device *ndev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct mvneta_port *pp = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
-- 
2.7.4
