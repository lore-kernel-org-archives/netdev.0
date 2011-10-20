From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 12/17] tc35815: Use standard phy_init_hw() instead of BMCR_RESET bit
Date: Thu, 20 Oct 2011 17:00:19 -0400
Message-ID: <1319144425-15547-13-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Paul <paul.gortmaker@windriver.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY should not be manually reset with the BMCR, as that will undo
board-specific PHY fixups and driver-specific phy->drv->config_init().

Instead, the PHY should be reset using phy_init_hw().

NOTE: Depends on earlier phy_init_hw() patch.

Not-yet-Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/tc35815.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 4a55a16..c3422f8 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1175,19 +1175,8 @@ static void tc35815_restart(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 
-	if (lp->phy_dev) {
-		int timeout;
-
-		phy_write(lp->phy_dev, MII_BMCR, BMCR_RESET);
-		timeout = 100;
-		while (--timeout) {
-			if (!(phy_read(lp->phy_dev, MII_BMCR) & BMCR_RESET))
-				break;
-			udelay(1);
-		}
-		if (!timeout)
-			printk(KERN_ERR "%s: BMCR reset failed.\n", dev->name);
-	}
+	if (lp->phy_dev)
+		phy_init_hw(lp->phy_dev);
 
 	spin_lock_bh(&lp->rx_lock);
 	spin_lock_irq(&lp->lock);
-- 
1.7.2.5
