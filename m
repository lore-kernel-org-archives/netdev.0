From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 01/11] net: bcmgenet: remove wol_enabled conditional code
Date: Mon, 21 Jul 2014 15:29:19 -0700
Message-ID: <1405981769-24618-2-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:56685 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754923AbaGUW3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:48 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so8500003pdi.34
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:48 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking for wol_enabled in bcmgenet_close() is bogus, since no other
code places set priv->wol_enabled. Remove that as it will conflict with
the upcoming and functional Wake-on-LAN implementation.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- remove one more call site which checked for wol_enabled

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 ---------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 -
 2 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 16281ad2da12..3cbf29095257 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1994,12 +1994,6 @@ static int bcmgenet_open(struct net_device *dev)
 
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
-	if (priv->wol_enabled) {
-		ret = bcmgenet_wol_resume(priv);
-		if (ret)
-			return ret;
-	}
-
 	if (phy_is_internal(priv->phydev)) {
 		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 		reg |= EXT_ENERGY_DET_MASK;
@@ -2161,9 +2155,6 @@ static int bcmgenet_close(struct net_device *dev)
 	if (phy_is_internal(priv->phydev))
 		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 
-	if (priv->wol_enabled)
-		clk_enable(priv->clk_wol);
-
 	if (!IS_ERR(priv->clk))
 		clk_disable_unprepare(priv->clk);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index e23c993b1362..f4891a1b6758 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -583,7 +583,6 @@ struct bcmgenet_priv {
 	struct platform_device *pdev;
 
 	/* WOL */
-	unsigned long wol_enabled;
 	struct clk *clk_wol;
 	u32 wolopts;
 
-- 
1.9.1
