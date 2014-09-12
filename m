From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCHv2] net/macb: Add hardware revision information during probe
Date: Sat, 13 Sep 2014 01:57:49 +0200
Message-ID: <1410566269-16445-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bo Shen <voice.shen@atmel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bo Shen <voice.shen@atmel.com>

Print the IP revision when probing.

Signed-off-by: Bo Shen <voice.shen@atmel.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Changes in v2:
 - condense information on one line

 drivers/net/ethernet/cadence/macb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ca5d7798b265..d9b8e94b805f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2241,9 +2241,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	netif_carrier_off(dev);
 
-	netdev_info(dev, "Cadence %s at 0x%08lx irq %d (%pM)\n",
-		    macb_is_gem(bp) ? "GEM" : "MACB", dev->base_addr,
-		    dev->irq, dev->dev_addr);
+	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
+		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
+		    dev->base_addr, dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
 	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-- 
1.9.1
