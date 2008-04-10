From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] macb: Call phy_disconnect on removing
Date: Thu, 10 Apr 2008 23:30:07 +0900 (JST)
Message-ID: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:55651 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756703AbYDJPJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:09:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call phy_disconnect() on remove routine.  Otherwise the phy timer
causes a kernel crash when unloading.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d210ed..10fcea5 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
+		if (bp->phy_dev)
+			phy_disconnect(bp->phy_dev);
 		mdiobus_unregister(&bp->mii_bus);
 		kfree(bp->mii_bus.irq);
 		unregister_netdev(dev);
