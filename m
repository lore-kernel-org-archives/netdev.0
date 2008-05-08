From: Ben Dooks <ben-linux@fluff.org>
Subject: DM9000: Update and fix driver debugging messages
Date: Thu, 8 May 2008 11:35:13 +0100
Message-ID: <20080508103513.GD30439@fluff.org.uk>
References: <20080428151309.GA30439@fluff.org.uk> <4820865F.70703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>,
	Linux Networking <netdev@vger.kernel.org>,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:54546 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760257AbYEHKfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 06:35:18 -0400
Content-Disposition: inline
In-Reply-To: <4820865F.70703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>

There was a missing newline in a dev_dbg() message.  Values read
from/written into PHY registers might be for interest too, so I added
new dbg messages there.

Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Signed-off-by: Ben Dooks <ben-linux@fluff.org>
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

