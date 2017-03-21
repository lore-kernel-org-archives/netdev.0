From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH net-next 5/7] net: phy: convert micrel to new
 read_mmd/write_mmd driver methods
Date: Tue, 21 Mar 2017 16:36:58 +0000
Message-ID: <E1cqMmI-0006wx-F9@rmk-PC.armlinux.org.uk>
References: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54104 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932589AbdCUQhi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:37:38 -0400
In-Reply-To: <20170321163555.GA21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert micrel to the new read_mmd/write_mmd driver methods.  This
Clause 22 PHY does not support any MMD access method.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/micrel.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 6742070ca676..b847184de6fc 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -637,8 +637,7 @@ static int ksz8873mll_config_aneg(struct phy_device *phydev)
  * MMD extended PHY registers.
  */
 static int
-ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
-		      int regnum)
+ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int devad, u16 regnum)
 {
 	return -1;
 }
@@ -646,10 +645,10 @@ ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 /* This routine does nothing since the Micrel ksz9021 does not support
  * standard IEEE MMD extended PHY registers.
  */
-static void
-ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
-		      int regnum, u32 val)
+static int
+ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int devad, u16 regnum, u16 val)
 {
+	return -1;
 }
 
 static int kszphy_get_sset_count(struct phy_device *phydev)
@@ -962,8 +961,8 @@ static struct phy_driver ksphy_driver[] = {
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.read_mmd_indirect = ksz9021_rd_mmd_phyreg,
-	.write_mmd_indirect = ksz9021_wr_mmd_phyreg,
+	.read_mmd	= ksz9021_rd_mmd_phyreg,
+	.write_mmd	= ksz9021_wr_mmd_phyreg,
 }, {
 	.phy_id		= PHY_ID_KSZ9031,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
-- 
2.7.4
