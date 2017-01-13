From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 5/7] net: phy: convert micrel to new read_mmd/write_mmd
 driver methods
Date: Fri, 13 Jan 2017 15:22:04 +0000
Message-ID: <E1cS3g4-0003Xq-1S@rmk-PC.armlinux.org.uk>
References: <20170113152059.GR14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>,
        linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:47284 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751952AbdAMPXN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 10:23:13 -0500
In-Reply-To: <20170113152059.GR14217@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert micrel to the new read_mmd/write_mmd driver methods.  This
Clause 22 PHY does not support any MMD access method.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/micrel.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 9a77289109b7..8d6432c23a14 100644
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
