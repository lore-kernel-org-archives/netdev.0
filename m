From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 5/6] bcm63xx_enet: drop unneeded NULL phy_clk check
Date: Sun,  1 Oct 2017 13:02:19 +0200
Message-ID: <20171001110220.27668-6-jonas.gorski@gmail.com>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33821 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdJALCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:18 -0400
Received: by mail-wm0-f67.google.com with SMTP id i131so1869742wma.1
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:17 -0700 (PDT)
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clk_disable and clk_unprepare are NULL-safe, so need to duplicate the
NULL check of the functions.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 059ef4f1d137..f6bc13fe8a99 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1903,8 +1903,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 out_uninit_hw:
 	/* turn off mdc clock */
 	enet_writel(priv, 0, ENET_MIISC_REG);
-	if (priv->phy_clk)
-		clk_disable_unprepare(priv->phy_clk);
+	clk_disable_unprepare(priv->phy_clk);
 
 out_disable_clk_mac:
 	clk_disable_unprepare(priv->mac_clk);
@@ -1943,9 +1942,7 @@ static int bcm_enet_remove(struct platform_device *pdev)
 	}
 
 	/* disable hw block clocks */
-	if (priv->phy_clk)
-		clk_disable_unprepare(priv->phy_clk);
-
+	clk_disable_unprepare(priv->phy_clk);
 	clk_disable_unprepare(priv->mac_clk);
 
 	free_netdev(dev);
-- 
2.13.2
