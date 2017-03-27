From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC v2 3/3] net: phy: allow EEE with SGMII interface modes
Date: Mon, 27 Mar 2017 10:59:01 +0100
Message-ID: <E1csRQT-0004rM-Tq@rmk-PC.armlinux.org.uk>
References: <20170327095826.GA2310@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36116 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751973AbdC0J7M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:59:12 -0400
In-Reply-To: <20170327095826.GA2310@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As EEE is able to work in SGMII mode as well, add it to the list of
permissable EEE modes that phy_init_eee() will accept.  This is
necessary so that EEE can work with an 88E1512 connected in SGMII mode.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 345251f21699..3529cc8bec10 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1215,6 +1215,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 	if ((phydev->duplex == DUPLEX_FULL) &&
 	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
+	     phydev->interface == PHY_INTERFACE_MODE_SGMII ||
 	     phy_interface_is_rgmii(phydev) ||
 	     phy_is_internal(phydev))) {
 		int eee_lp, eee_cap, eee_adv;
-- 
2.7.4
