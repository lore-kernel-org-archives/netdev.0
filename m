From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH] lpc_eth: remove obsolete ifdefs
Date: Wed,  8 Aug 2012 15:18:54 +0200
Message-ID: <1344431934-16748-1-git-send-email-stigge@antcom.de>
Cc: Roland Stigge <stigge@antcom.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, aletes.xgr@gmail.com,
	kevin.wells@nxp.com, srinivas.bakki@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The #ifdefs regarding CONFIG_ARCH_LPC32XX_MII_SUPPORT and
CONFIG_ARCH_LPC32XX_IRAM_FOR_NET are obsolete since the symbols have been
removed from Kconfig and replaced by devicetree based configuration.

Signed-off-by: Roland Stigge <stigge@antcom.de>

---
 drivers/net/ethernet/nxp/lpc_eth.c |   13 -------------
 1 file changed, 13 deletions(-)

--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -346,28 +346,15 @@ static phy_interface_t lpc_phy_interface
 						   "phy-mode", NULL);
 		if (mode && !strcmp(mode, "mii"))
 			return PHY_INTERFACE_MODE_MII;
-		return PHY_INTERFACE_MODE_RMII;
 	}
-
-	/* non-DT */
-#ifdef CONFIG_ARCH_LPC32XX_MII_SUPPORT
-	return PHY_INTERFACE_MODE_MII;
-#else
 	return PHY_INTERFACE_MODE_RMII;
-#endif
 }
 
 static bool use_iram_for_net(struct device *dev)
 {
 	if (dev && dev->of_node)
 		return of_property_read_bool(dev->of_node, "use-iram");
-
-	/* non-DT */
-#ifdef CONFIG_ARCH_LPC32XX_IRAM_FOR_NET
-	return true;
-#else
 	return false;
-#endif
 }
 
 /* Receive Status information word */
