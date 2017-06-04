From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH] net/3com: Make el3_netdev_get_ecmd return void
Date: Sun,  4 Jun 2017 20:24:46 +0300
Message-ID: <20170604172446.4294-1-yuval.shaia@oracle.com>
To: davem@davemloft.net, yuval.shaia@oracle.com, jarod@redhat.com,
        tremyfr@gmail.com, dhowells@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23666 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdFDRZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 13:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make return value void since function never returns meaningfull value.

Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
---
 drivers/net/ethernet/3com/3c509.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index db8592d..f66c971 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1039,7 +1039,7 @@ el3_link_ok(struct net_device *dev)
 	return tmp & (1<<11);
 }
 
-static int
+static void
 el3_netdev_get_ecmd(struct net_device *dev, struct ethtool_link_ksettings *cmd)
 {
 	u16 tmp;
@@ -1082,7 +1082,6 @@ el3_netdev_get_ecmd(struct net_device *dev, struct ethtool_link_ksettings *cmd)
 						supported);
 	cmd->base.speed = SPEED_10;
 	EL3WINDOW(1);
-	return 0;
 }
 
 static int
@@ -1151,12 +1150,11 @@ static int el3_get_link_ksettings(struct net_device *dev,
 				  struct ethtool_link_ksettings *cmd)
 {
 	struct el3_private *lp = netdev_priv(dev);
-	int ret;
 
 	spin_lock_irq(&lp->lock);
-	ret = el3_netdev_get_ecmd(dev, cmd);
+	el3_netdev_get_ecmd(dev, cmd);
 	spin_unlock_irq(&lp->lock);
-	return ret;
+	return 0;
 }
 
 static int el3_set_link_ksettings(struct net_device *dev,
-- 
2.9.4
