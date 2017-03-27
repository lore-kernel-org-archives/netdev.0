From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 21:15:29 +0100
Message-ID: <20170327201529.GT7909@n2100.armlinux.org.uk>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
 <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
 <5d3c3ce0-fabc-6b96-c7e9-c2e46ffe4d23@gmail.com>
 <20170327170019.GR7909@n2100.armlinux.org.uk>
 <9f523664-9479-26ca-e3f7-95453ed03560@gmail.com>
 <20170327194747.GS7909@n2100.armlinux.org.uk>
 <705b10f9-6a0c-3a35-ddff-04b75c6f80ec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43598 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbdC0UPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:15:41 -0400
Content-Disposition: inline
In-Reply-To: <705b10f9-6a0c-3a35-ddff-04b75c6f80ec@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's the revised patch as requested.

Thanks.

8<===
From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: phy: allow EEE with any interface mode

EEE is able to work in any PHY interface mode, there is nothing which
fundamentally restricts it to only a few modes.  For example, EEE works
in SGMII mode with the Marvell 88E1512.

Rather than just adding SGMII mode to the list, Florian suggests
removing the list of interface modes entirely:

  It actually sounds like we should just kill the check entirely,
  it does not appear that any of the interface mode would not
  fundamentally be able to support EEE, because the "lowest" mode
  we support is MII, and even there it's quite possible to support
  EEE.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 345251f21699..867c42154087 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1208,15 +1208,8 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		return -EIO;
 
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
-	 * Also EEE feature is active when core is operating with MII, GMII
-	 * or RGMII (all kinds). Internal PHYs are also allowed to proceed and
-	 * should return an error if they do not support EEE.
 	 */
-	if ((phydev->duplex == DUPLEX_FULL) &&
-	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
-	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
-	     phy_interface_is_rgmii(phydev) ||
-	     phy_is_internal(phydev))) {
+	if (phydev->duplex == DUPLEX_FULL) {
 		int eee_lp, eee_cap, eee_adv;
 		u32 lp, cap, adv;
 		int status;
-- 
2.7.4


-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
