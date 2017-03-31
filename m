From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH v3 3/3] net: phy: allow EEE with any interface mode
Date: Fri, 31 Mar 2017 10:37:18 +0100
Message-ID: <E1ctsze-00063c-EC@rmk-PC.armlinux.org.uk>
References: <20170331093645.GA15329@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:48496 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932918AbdCaJh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:37:26 -0400
In-Reply-To: <20170331093645.GA15329@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
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
