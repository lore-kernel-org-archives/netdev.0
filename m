From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 1/9] net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
Date: Tue,  6 May 2014 14:20:50 -0300
Message-ID: <1399396858-14551-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53517 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750939AbaEFRVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:21:37 -0400
In-Reply-To: <1399396858-14551-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, mv643xx_eth_adjust_link() is only used to call mv643xx_adjust_pscr().
This commit renames the latter to the former, and therefore removes the extra
and useless function.

Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index b7b8d74..b75965f3 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1010,8 +1010,9 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 
 
 /* mii management interface *************************************************/
-static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
+static void mv643xx_eth_adjust_link(struct net_device *dev)
 {
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
 	u32 autoneg_disable = FORCE_LINK_PASS |
 	             DISABLE_AUTO_NEG_SPEED_GMII |
@@ -1387,7 +1388,7 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	ret = phy_ethtool_sset(mp->phy, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2303,7 +2304,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2701,13 +2702,6 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
-static void mv643xx_eth_adjust_link(struct net_device *dev)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-
-	mv643xx_adjust_pscr(mp);
-}
-
 static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
 				   int phy_addr)
 {
-- 
1.9.1
