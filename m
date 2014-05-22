From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 1/8] net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
Date: Thu, 22 May 2014 20:06:56 -0300
Message-ID: <1400800023-1562-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49692 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753121AbaEVXHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:07:55 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
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
index 3b0f818..c68ff5d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1167,8 +1167,9 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 
 
 /* mii management interface *************************************************/
-static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
+static void mv643xx_eth_adjust_link(struct net_device *dev)
 {
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
 	u32 autoneg_disable = FORCE_LINK_PASS |
 	             DISABLE_AUTO_NEG_SPEED_GMII |
@@ -1544,7 +1545,7 @@ mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	ret = phy_ethtool_sset(mp->phy, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2473,7 +2474,7 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	ret = phy_mii_ioctl(mp->phy, ifr, cmd);
 	if (!ret)
-		mv643xx_adjust_pscr(mp);
+		mv643xx_eth_adjust_link(dev);
 	return ret;
 }
 
@@ -2871,13 +2872,6 @@ static void set_params(struct mv643xx_eth_private *mp,
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
