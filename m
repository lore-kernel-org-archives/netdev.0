From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/2] net: mvpp2: fix 10 Mbit/s usage
Date: Sun, 27 Jul 2014 23:21:35 +0200
Message-ID: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:35488 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752551AbaG0VVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 17:21:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit is similar to commit 4d12bc63ab5e ("net: mvneta: fix
operation in 10 Mbit/s mode"), but this time for the mvpp2 driver. The
driver was properly taking into account the 1 Gbit/s and 100 Mbit/s
speeds, but not the 10 Mbit/s, which was handled as 100
Mbit/s. However, the MVPP2_GMAC_CONFIG_MII_SPEED bit in the
MVPP2_GMAC_AUTONEG_CONFIG register must remain cleared to allow 10
Mbit/s operation. This commit therefore fixes 10 Mbit/s operation.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
This commit applies on top of net-next, since the mvpp2 driver was
merged there.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3193a7d..3cae3d2 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4842,7 +4842,7 @@ static void mvpp2_link_event(struct net_device *dev)
 
 			if (phydev->speed == SPEED_1000)
 				val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
-			else
+			else if (phydev->speed == SPEED_100)
 				val |= MVPP2_GMAC_CONFIG_MII_SPEED;
 
 			writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
-- 
2.0.0
