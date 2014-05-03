From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 1/7] net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
Date: Sat,  3 May 2014 15:26:56 -0300
Message-ID: <1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60613 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752218AbaECS2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:06 -0400
In-Reply-To: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, mv643xx_eth_adjust_link() is only used to call mv643xx_adjust_pscr().
This commit renames the latter to the former, and therefore removes the extra
and useless function.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index b7b8d74..1e63c63 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1010,8 +1010,10 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 
 
 /* mii management interface *************************************************/
-static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
+static void mv643xx_eth_adjust_link(struct net_device *dev)
 {
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
 	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
 	u32 autoneg_disable = FORCE_LINK_PASS |
 	             DISABLE_AUTO_NEG_SPEED_GMII |
@@ -1387,7 +1389,7 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	ret = phy_ethtool_sset(mp->phy, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2303,7 +2305,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2701,13 +2703,6 @@ static void set_params(struct mv643xx_eth_private *mp,
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
