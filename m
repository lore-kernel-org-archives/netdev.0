From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 11/17] mv643xx_eth: remove force_phy_addr field
Date: Wed,  3 Sep 2008 14:29:38 +0200
Message-ID: <1220444984-20150-12-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52901 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751572AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there are two different fields in the
mv643xx_eth_platform_data struct that together describe the PHY
address -- one field (phy_addr) has the address of the PHY, but if
that address is zero, a second field (force_phy_addr) needs to be
set to distinguish the actual address zero from a zero due to not
having filled in the PHY address explicitly (which should mean
'use the default PHY address').

If we are a bit smarter about the encoding of the phy_addr field,
we can avoid the need for a second field -- this patch does that.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/arm/mach-kirkwood/db88f6281-bp-setup.c  |    2 +-
 arch/arm/mach-kirkwood/rd88f6192-nas-setup.c |    2 +-
 arch/arm/mach-kirkwood/rd88f6281-setup.c     |    2 +-
 arch/arm/mach-loki/lb88rc8480-setup.c        |    2 +-
 arch/arm/mach-mv78xx0/db78x00-bp-setup.c     |    8 ++++----
 arch/arm/mach-orion5x/db88f5281-setup.c      |    2 +-
 arch/arm/mach-orion5x/dns323-setup.c         |    2 +-
 arch/arm/mach-orion5x/kurobox_pro-setup.c    |    2 +-
 arch/arm/mach-orion5x/mss2-setup.c           |    2 +-
 arch/arm/mach-orion5x/mv2120-setup.c         |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    2 +-
 arch/arm/mach-orion5x/rd88f5182-setup.c      |    2 +-
 arch/arm/mach-orion5x/ts78xx-setup.c         |    3 +--
 arch/arm/mach-orion5x/tsx09-common.c         |    2 +-
 arch/arm/mach-orion5x/wnr854t-setup.c        |    2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    2 +-
 arch/powerpc/sysdev/mv64x60_dev.c            |    6 ++----
 drivers/net/mv643xx_eth.c                    |    4 ++--
 include/linux/mv643xx_eth.h                  |    5 ++++-
 20 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/arch/arm/mach-kirkwood/db88f6281-bp-setup.c b/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
index 610fb24..cd31779 100644
--- a/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
+++ b/arch/arm/mach-kirkwood/db88f6281-bp-setup.c
@@ -25,7 +25,7 @@
 #include "common.h"
 
 static struct mv643xx_eth_platform_data db88f6281_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data db88f6281_sata_data = {
diff --git a/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c b/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
index a3012d4..b1d1a87 100644
--- a/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6192-nas-setup.c
@@ -30,7 +30,7 @@
 #define RD88F6192_GPIO_USB_VBUS		10
 
 static struct mv643xx_eth_platform_data rd88f6192_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data rd88f6192_sata_data = {
diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index d96487a..b641661 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -69,7 +69,7 @@ static struct platform_device rd88f6281_nand_flash = {
 };
 
 static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-loki/lb88rc8480-setup.c b/arch/arm/mach-loki/lb88rc8480-setup.c
index 2cc9ac9..85f9c12 100644
--- a/arch/arm/mach-loki/lb88rc8480-setup.c
+++ b/arch/arm/mach-loki/lb88rc8480-setup.c
@@ -67,7 +67,7 @@ static struct platform_device lb88rc8480_boot_flash = {
 };
 
 static struct mv643xx_eth_platform_data lb88rc8480_ge0_data = {
-	.phy_addr	= 1,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
 	.mac_addr	= { 0x00, 0x50, 0x43, 0x11, 0x22, 0x33 },
 };
 
diff --git a/arch/arm/mach-mv78xx0/db78x00-bp-setup.c b/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
index a2d0c97..49f434c 100644
--- a/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
+++ b/arch/arm/mach-mv78xx0/db78x00-bp-setup.c
@@ -19,19 +19,19 @@
 #include "common.h"
 
 static struct mv643xx_eth_platform_data db78x00_ge00_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge01_data = {
-	.phy_addr	= 9,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(9),
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge10_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 };
 
 static struct mv643xx_eth_platform_data db78x00_ge11_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 };
 
 static struct mv_sata_platform_data db78x00_sata_data = {
diff --git a/arch/arm/mach-orion5x/db88f5281-setup.c b/arch/arm/mach-orion5x/db88f5281-setup.c
index ff13e90..d318bea 100644
--- a/arch/arm/mach-orion5x/db88f5281-setup.c
+++ b/arch/arm/mach-orion5x/db88f5281-setup.c
@@ -285,7 +285,7 @@ subsys_initcall(db88f5281_pci_init);
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data db88f5281_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/dns323-setup.c b/arch/arm/mach-orion5x/dns323-setup.c
index 1a1d84b..3ec8ade 100644
--- a/arch/arm/mach-orion5x/dns323-setup.c
+++ b/arch/arm/mach-orion5x/dns323-setup.c
@@ -79,7 +79,7 @@ subsys_initcall(dns323_pci_init);
  */
 
 static struct mv643xx_eth_platform_data dns323_eth_data = {
-	.phy_addr = 8,
+	.phy_addr = MV643XX_ETH_PHY_ADDR(8),
 };
 
 /****************************************************************************
diff --git a/arch/arm/mach-orion5x/kurobox_pro-setup.c b/arch/arm/mach-orion5x/kurobox_pro-setup.c
index cb72f1b..945d3c3 100644
--- a/arch/arm/mach-orion5x/kurobox_pro-setup.c
+++ b/arch/arm/mach-orion5x/kurobox_pro-setup.c
@@ -159,7 +159,7 @@ subsys_initcall(kurobox_pro_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data kurobox_pro_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/mss2-setup.c b/arch/arm/mach-orion5x/mss2-setup.c
index 53ff189..68acca9 100644
--- a/arch/arm/mach-orion5x/mss2-setup.c
+++ b/arch/arm/mach-orion5x/mss2-setup.c
@@ -109,7 +109,7 @@ subsys_initcall(mss2_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data mss2_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/mv2120-setup.c b/arch/arm/mach-orion5x/mv2120-setup.c
index 978d4d5..97c9ccb 100644
--- a/arch/arm/mach-orion5x/mv2120-setup.c
+++ b/arch/arm/mach-orion5x/mv2120-setup.c
@@ -39,7 +39,7 @@
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data mv2120_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static struct mv_sata_platform_data mv2120_sata_data = {
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index e72fe1e..500cdad 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -88,7 +88,7 @@ static struct orion5x_mpp_mode rd88f5181l_fxo_mpp_modes[] __initdata = {
 };
 
 static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index a1fe325..ebde814 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -89,7 +89,7 @@ static struct orion5x_mpp_mode rd88f5181l_ge_mpp_modes[] __initdata = {
 };
 
 static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/rd88f5182-setup.c b/arch/arm/mach-orion5x/rd88f5182-setup.c
index 4c3bcd7..a04f9e4 100644
--- a/arch/arm/mach-orion5x/rd88f5182-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5182-setup.c
@@ -221,7 +221,7 @@ subsys_initcall(rd88f5182_pci_init);
  ****************************************************************************/
 
 static struct mv643xx_eth_platform_data rd88f5182_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/ts78xx-setup.c b/arch/arm/mach-orion5x/ts78xx-setup.c
index ae0a5dc..1368e9f 100644
--- a/arch/arm/mach-orion5x/ts78xx-setup.c
+++ b/arch/arm/mach-orion5x/ts78xx-setup.c
@@ -103,8 +103,7 @@ static struct platform_device ts78xx_nor_boot_flash = {
  * Ethernet
  ****************************************************************************/
 static struct mv643xx_eth_platform_data ts78xx_eth_data = {
-	.phy_addr	= 0,
-	.force_phy_addr = 1,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
 };
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/tsx09-common.c b/arch/arm/mach-orion5x/tsx09-common.c
index 83feac3..19cde24 100644
--- a/arch/arm/mach-orion5x/tsx09-common.c
+++ b/arch/arm/mach-orion5x/tsx09-common.c
@@ -48,7 +48,7 @@ void qnap_tsx09_power_off(void)
  ****************************************************************************/
 
 struct mv643xx_eth_platform_data qnap_tsx09_eth_data = {
-	.phy_addr	= 8,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
 };
 
 static int __init qnap_tsx09_parse_hex_nibble(char n)
diff --git a/arch/arm/mach-orion5x/wnr854t-setup.c b/arch/arm/mach-orion5x/wnr854t-setup.c
index b6bc43e..7ddc22c 100644
--- a/arch/arm/mach-orion5x/wnr854t-setup.c
+++ b/arch/arm/mach-orion5x/wnr854t-setup.c
@@ -92,7 +92,7 @@ static struct platform_device wnr854t_nor_flash = {
 };
 
 static struct mv643xx_eth_platform_data wnr854t_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index b10da17..9a4fd52 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -100,7 +100,7 @@ static struct platform_device wrt350n_v2_nor_flash = {
 };
 
 static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
-	.phy_addr	= -1,
+	.phy_addr	= MV643XX_ETH_PHY_NONE,
 	.speed		= SPEED_1000,
 	.duplex		= DUPLEX_FULL,
 };
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 32e0ad0..b6bd775 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -293,10 +293,8 @@ static int __init mv64x60_eth_device_setup(struct device_node *np, int id,
 		return -ENODEV;
 
 	prop = of_get_property(phy, "reg", NULL);
-	if (prop) {
-		pdata.force_phy_addr = 1;
-		pdata.phy_addr = *prop;
-	}
+	if (prop)
+		pdata.phy_addr = MV643XX_ETH_PHY_ADDR(*prop);
 
 	of_node_put(phy);
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6d3da78..b4850cf 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2412,10 +2412,10 @@ static void set_params(struct mv643xx_eth_private *mp,
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
-	if (pd->phy_addr == -1) {
+	if (pd->phy_addr == MV643XX_ETH_PHY_NONE) {
 		mp->phy_addr = -1;
 	} else {
-		if (pd->force_phy_addr || pd->phy_addr) {
+		if (pd->phy_addr != MV643XX_ETH_PHY_ADDR_DEFAULT) {
 			mp->phy_addr = pd->phy_addr & 0x3f;
 			phy_addr_set(mp, mp->phy_addr);
 		} else {
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 12339eb..cbbbe9b 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -21,6 +21,10 @@ struct mv643xx_eth_shared_platform_data {
 	unsigned int		t_clk;
 };
 
+#define MV643XX_ETH_PHY_ADDR_DEFAULT	0
+#define MV643XX_ETH_PHY_ADDR(x)		(0x80 | (x))
+#define MV643XX_ETH_PHY_NONE		0xff
+
 struct mv643xx_eth_platform_data {
 	/*
 	 * Pointer back to our parent instance, and our port number.
@@ -31,7 +35,6 @@ struct mv643xx_eth_platform_data {
 	/*
 	 * Whether a PHY is present, and if yes, at which address.
 	 */
-	int			force_phy_addr;
 	int			phy_addr;
 
 	/*
-- 
1.5.6.4

