From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 3/7] net: lan78xx: update for
 phy_(read|write)_mmd_indirect() removal
Date: Sun, 19 Mar 2017 11:00:29 +0000
Message-ID: <E1cpYZZ-0006Uj-8Z@rmk-PC.armlinux.org.uk>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43358 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752075AbdCSLKa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:10:30 -0400
In-Reply-To: <20170319105943.GR21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lan78xx appears to use phylib in a rather weird way, accessing the PHY
partly through phylib, and partly by makign direct accesses to it,
including to the Clause 45 registers.  As the indirect MMD accessors are
going away, update this driver to use the plain phy_(read|write)_mmd()
accessors instead.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/usb/lan78xx.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 9889a70ff4f6..d885e0325422 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1952,10 +1952,10 @@ static int lan8835_fixup(struct phy_device *phydev)
 	struct lan78xx_net *dev = netdev_priv(phydev->attached_dev);
 
 	/* LED2/PME_N/IRQ_N/RGMII_ID pin to IRQ_N mode */
-	buf = phy_read_mmd_indirect(phydev, 0x8010, 3);
+	buf = phy_read_mmd(phydev, MDIO_MMD_PCS, 0x8010);
 	buf &= ~0x1800;
 	buf |= 0x0800;
-	phy_write_mmd_indirect(phydev, 0x8010, 3, buf);
+	phy_write_mmd(phydev, MDIO_MMD_PCS, 0x8010, buf);
 
 	/* RGMII MAC TXC Delay Enable */
 	ret = lan78xx_write_reg(dev, MAC_RGMII_ID,
@@ -1975,11 +1975,11 @@ static int ksz9031rnx_fixup(struct phy_device *phydev)
 
 	/* Micrel9301RNX PHY configuration */
 	/* RGMII Control Signal Pad Skew */
-	phy_write_mmd_indirect(phydev, 4, 2, 0x0077);
+	phy_write_mmd(phydev, MDIO_MMD_WIS, 4, 0x0077);
 	/* RGMII RX Data Pad Skew */
-	phy_write_mmd_indirect(phydev, 5, 2, 0x7777);
+	phy_write_mmd(phydev, MDIO_MMD_WIS, 5, 0x7777);
 	/* RGMII RX Clock Pad Skew */
-	phy_write_mmd_indirect(phydev, 8, 2, 0x1FF);
+	phy_write_mmd(phydev, MDIO_MMD_WIS, 8, 0x1FF);
 
 	dev->interface = PHY_INTERFACE_MODE_RGMII_RXID;
 
-- 
2.7.4
