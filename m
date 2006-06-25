From: akpm@osdl.org
Subject: [patch 3/3] Fix phy id for LXT971A/LXT972A
Date: Sun, 25 Jun 2006 01:44:37 -0700
Message-ID: <200606250844.k5P8ichl020797@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, Uwe_Zeisberger@digi.com,
	afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13202 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751068AbWFYIo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 04:44:56 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Uwe Zeisberger <Uwe_Zeisberger@digi.com>

The phy ids used are taken from an driver that used a right shift of 4 to chop
off the revision number.  This driver does not shift, so the id and mask
values are wrong and must be left shifted by 4 to actually detect the chips.

Signed-off-by: Uwe Zeisberger <Uwe_Zeisberger@digi.com>
Acked-by: Andy Fleming <afleming@freescale.com>

[akpm: this is a previously-nacked patch, but the problem is real]
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/phy/lxt.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/phy/lxt.c~fix-phy-id-for-lxt971a-lxt972a drivers/net/phy/lxt.c
--- a/drivers/net/phy/lxt.c~fix-phy-id-for-lxt971a-lxt972a
+++ a/drivers/net/phy/lxt.c
@@ -123,9 +123,9 @@ static int lxt971_config_intr(struct phy
 }
 
 static struct phy_driver lxt970_driver = {
-	.phy_id		= 0x07810000,
+	.phy_id		= 0x78100000,
 	.name		= "LXT970",
-	.phy_id_mask	= 0x0fffffff,
+	.phy_id_mask	= 0xfffffff0,
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= lxt970_config_init,
@@ -137,9 +137,9 @@ static struct phy_driver lxt970_driver =
 };
 
 static struct phy_driver lxt971_driver = {
-	.phy_id		= 0x0001378e,
+	.phy_id		= 0x001378e0,
 	.name		= "LXT971",
-	.phy_id_mask	= 0x0fffffff,
+	.phy_id_mask	= 0xfffffff0,
 	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
_
