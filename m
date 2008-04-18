From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Subject: [PATCH] DM9000: improved/fixed dev_dbg() messages
Date: Fri, 18 Apr 2008 12:02:16 +0200
Message-ID: <1208512936-5897-3-git-send-email-enrico.scholz@sigma-chemnitz.de>
Cc: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cvg.de ([62.153.82.30]:54234 "EHLO mail.cvg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754660AbYDRKOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 06:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a missing newline in a dev_dbg() message.  Values read
from/written into PHY registers might be for interest too, so I added
new dbg messages there.

Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
---
 drivers/net/dm9000.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 7bc16d2..e4af7a9 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -525,7 +525,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	dev_dbg(&pdev->dev, "dm9000_probe()");
+	dev_dbg(&pdev->dev, "dm9000_probe()\n");
 
 	/* setup board info structure */
 	db = (struct board_info *) ndev->priv;
@@ -1292,6 +1292,8 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	spin_unlock_irqrestore(&db->lock,flags);
 
 	mutex_unlock(&db->addr_lock);
+
+	dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
 	return ret;
 }
 
@@ -1305,6 +1307,7 @@ dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
 	unsigned long flags;
 	unsigned long reg_save;
 
+	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
 	mutex_lock(&db->addr_lock);
 
 	spin_lock_irqsave(&db->lock,flags);
-- 
1.5.4.1

