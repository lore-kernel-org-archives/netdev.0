From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] bcm87xx: disable autonegotiation by default
Date: Wed,  4 Jul 2012 12:33:57 +0200
Message-ID: <1341398037-7591-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, david.daney@cavium.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41698 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010Ab2GDKeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 06:34:09 -0400
Received: by werb14 with SMTP id b14so4261106wer.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 03:34:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bcm87xx phys don't support autonegotiation, so don't use it by
default, as otherwise phy_state_machine() will try to enable it (using
c22 requests, which also don't make any sense for the bcm78xx).

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
Tested on a bcm8707, which uses the same id as 8727

 drivers/net/phy/bcm87xx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index f5f0562..9a90dcf 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -89,6 +89,7 @@ static int bcm87xx_config_init(struct phy_device *phydev)
 	phydev->supported = SUPPORTED_10000baseR_FEC;
 	phydev->advertising = ADVERTISED_10000baseR_FEC;
 	phydev->state = PHY_NOLINK;
+	phydev->autoneg = AUTONEG_DISABLE;
 
 	bcm87xx_of_reg_init(phydev);
 
-- 
1.7.10
