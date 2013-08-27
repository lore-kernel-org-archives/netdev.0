From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH] net/cadence/macb: fix invalid 0 return if no phy is discovered on mii init
Date: Tue, 27 Aug 2013 14:36:14 +0200
Message-ID: <1377606974-21240-1-git-send-email-b.brezillon@overkiz.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace misleading -1 (-EPERM) by a more appropriate return code (-ENXIO)
in macb_mii_probe function.
Save macb_mii_probe return before branching to err_out_unregister to avoid
erronous 0 return.

Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index fe06ab0..7660c45 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -276,7 +276,7 @@ static int macb_mii_probe(struct net_device *dev)
 	phydev = phy_find_first(bp->mii_bus);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
-		return -1;
+		return -ENXIO;
 	}
 
 	pdata = dev_get_platdata(&bp->pdev->dev);
@@ -379,9 +379,9 @@ int macb_mii_init(struct macb *bp)
 	if (err)
 		goto err_out_free_mdio_irq;
 
-	if (macb_mii_probe(bp->dev) != 0) {
+	err = macb_mii_probe(bp->dev);
+	if (err)
 		goto err_out_unregister_bus;
-	}
 
 	return 0;
 
-- 
1.7.9.5
