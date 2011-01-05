From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] net: ixp4xx_eth: Return proper error for eth_init_one
Date: Wed, 05 Jan 2011 13:24:06 +0800
Message-ID: <1294205046.8294.2.camel@mola>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return PTR_ERR(port->phydev) instead of 1 if phy_connect failed.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/arm/ixp4xx_eth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 6028226..9eb9b98 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1229,8 +1229,10 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
-	if ((err = IS_ERR(port->phydev)))
+	if (IS_ERR(port->phydev)) {
+		err = PTR_ERR(port->phydev);
 		goto err_free_mem;
+	}
 
 	port->phydev->irq = PHY_POLL;
 
-- 
1.7.2
