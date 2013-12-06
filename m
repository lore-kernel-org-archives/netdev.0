From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 8/9] net: tc35815: use phy_init_hw for PHY reset
Date: Thu, 5 Dec 2013 16:55:16 -0800
Message-ID: <1386291317-1202-9-git-send-email-f.fainelli@gmail.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:64935 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab3LFBFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:05:02 -0500
In-Reply-To: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of open-coding the PHY reset through MII BMCR, use phy_init_hw()
which does that for us and also makes sure that any PHY specific fixups
are applied.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/toshiba/tc35815.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 1322546..f6b3212 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -1170,19 +1170,12 @@ static int tc35815_tx_full(struct net_device *dev)
 static void tc35815_restart(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
+	int ret;
 
 	if (lp->phy_dev) {
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
+		ret = phy_init_hw(lp->phy_dev);
+		if (ret)
+			printk(KERN_ERR "%s: PHY init failed.\n", dev->name);
 	}
 
 	spin_lock_bh(&lp->rx_lock);
-- 
1.8.3.2
