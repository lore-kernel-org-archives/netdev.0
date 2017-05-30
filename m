From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: phy: fix marvell phy status reading
Date: Tue, 30 May 2017 16:21:51 +0100
Message-ID: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:51158 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdE3PVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:21:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell driver incorrectly provides phydev->lp_advertising as the
logical and of the link partner's advert and our advert.  This is
incorrect - this field is supposed to store the link parter's unmodified
advertisment.

This allows ethtool to report the correct link partner auto-negotiation
status.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/marvell.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e38f84291258..f93a7a46feb7 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1119,8 +1119,6 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
 		if (adv < 0)
 			return adv;
 
-		lpa &= adv;
-
 		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
 			phydev->duplex = DUPLEX_FULL;
 		else
-- 
2.7.4
