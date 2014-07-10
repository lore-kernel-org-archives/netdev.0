From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 01/11] net: bcmgenet: remove wol_enabled conditional code
Date: Thu, 10 Jul 2014 15:46:14 -0700
Message-ID: <1405032384-24006-2-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:60092 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbaGJWq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:29 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so239715iec.10
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:28 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking for wol_enabled in bcmgenet_close() is bogus, since no other
code places set priv->wol_enabled. Remove that as it will conflict with
the upcoming and functional Wake-on-LAN implementation.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 ---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 -
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5ba1cfbd60da..cece54e68b88 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2168,9 +2168,6 @@ static int bcmgenet_close(struct net_device *dev)
 	if (phy_is_internal(priv->phydev))
 		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 
-	if (priv->wol_enabled)
-		clk_enable(priv->clk_wol);
-
 	if (!IS_ERR(priv->clk))
 		clk_disable_unprepare(priv->clk);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 0f117105fed1..b3a5b49a7610 100644
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
