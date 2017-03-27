From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net-next 3/3] net: phy: stop the PHY clock during LPI only if supported
Date: Mon, 27 Mar 2017 11:47:21 -0700
Message-ID: <20170327184721.30275-4-f.fainelli@gmail.com>
References: <20170327184721.30275-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35314 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdC0Srz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:47:55 -0400
Received: by mail-qt0-f194.google.com with SMTP id r5so8935638qtb.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:47:49 -0700 (PDT)
In-Reply-To: <20170327184721.30275-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we detect whether a PHY supports stopping its clock during LPI,
deny a call to phy_init_eee() with clk_stop_enable being set and the PHY
not supporting that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ba4676ee9018..1c3800e01d82 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1251,7 +1251,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		if (!phy_check_valid(phydev->speed, phydev->duplex, lp & adv))
 			goto eee_exit_err;
 
-		if (clk_stop_enable) {
+		if (clk_stop_enable && phydev->clk_stop_cap) {
 			/* Configure the PHY to stop receiving xMII
 			 * clock while it is signaling LPI.
 			 */
-- 
2.9.3
