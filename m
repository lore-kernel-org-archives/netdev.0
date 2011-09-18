From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 3/4] net/fec: set phy_speed to the optimal frequency 2.5 MHz
Date: Sun, 18 Sep 2011 19:54:11 +0800
Message-ID: <1316346852-17090-4-git-send-email-shawn.guo@linaro.org>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org,
	Shawn Guo <shawn.guo@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:43420 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1IRLxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 07:53:12 -0400
Received: by gwb17 with SMTP id 17so5782187gwb.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 04:53:12 -0700 (PDT)
In-Reply-To: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the unnecessary 1 bit left-shift on fep->phy_speed during the
calculation, the phy_speed always runs at the half frequency of the
optimal one 2.5 MHz.

The patch removes that 1 bit left-shift to get the optimal phy_speed.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 5ef0e34..04206e4 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1007,7 +1007,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	/*
 	 * Set MII speed to 2.5 MHz (= clk_get_rate() / 2 * phy_speed)
 	 */
-	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000) << 1;
+	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
 	fep->mii_bus = mdiobus_alloc();
-- 
1.7.4.1
