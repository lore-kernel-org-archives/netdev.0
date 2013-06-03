From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: sun4i-emac: remove erroneous assignment
Date: Mon, 03 Jun 2013 23:36:50 +0200
Message-ID: <3298610.K0DeJZEM4E@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Richard Genoud <richard.genoud@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:57699 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315Ab3FCVgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:36:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added sun4i-emac driver causes a build error when
CONFIG_NET_POLL_CONTROLLER is set, because it attempts to
assign a pointer to netdev->poll_controller, which has
been replaced with ops->ndo_poll_controller in 2.6.31!

The correct assignment is present as well, so we just need
to remove the wrong one.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Stefan Roese <sr@denx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Richard Genoud <richard.genoud@gmail.com>
---
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index b411344..3e7b220 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -869,10 +869,6 @@ static int emac_probe(struct platform_device *pdev)
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->ethtool_ops = &emac_ethtool_ops;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = &emac_poll_controller;
-#endif
-
 	platform_set_drvdata(pdev, ndev);
 
 	/* Carrier starts down, phylib will bring it up */
