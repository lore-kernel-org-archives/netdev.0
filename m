From: Hui Wang <jason77.wang@gmail.com>
Subject: [PATCH] phy/micrel: change phy_id_mask for KSZ9021 and KS8001
Date: Mon, 18 Jun 2012 16:52:09 +0800
Message-ID: <1340009529-4231-1-git-send-email-jason77.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <david.choi@micrel.com>, <davem@davemloft.net>,
	<nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50517 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437Ab2FRIwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 04:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a freescale imx6q platform, a hardware phy chip KSZ9021 is
recognized as a KS8001 chip by the current driver like this:
eth0: Freescale FEC PHY driver [Micrel KS8001 or KS8721]

KSZ9021 has phy_id 0x00221610, while KSZ8001 has phy_id
0x0022161a, the current phy_id_mask (0x00fffff0/0x00ffff10) can't
distinguish them. So change phy_id_mask to resolve this problem.

Although the micrel datasheet says that the 4 LSB of phyid2 register
contains the chip revision number and the current driver is designed
to follow this rule, in reality the chip implementation doesn't follow
it.

Cc: David J. Choi <david.choi@micrel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Signed-off-by: Hui Wang <jason77.wang@gmail.com>
---
 drivers/net/phy/micrel.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 590f902..9d6c80c 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -161,7 +161,7 @@ static struct phy_driver ks8051_driver = {
 static struct phy_driver ks8001_driver = {
 	.phy_id		= PHY_ID_KS8001,
 	.name		= "Micrel KS8001 or KS8721",
-	.phy_id_mask	= 0x00fffff0,
+	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
@@ -174,7 +174,7 @@ static struct phy_driver ks8001_driver = {
 
 static struct phy_driver ksz9021_driver = {
 	.phy_id		= PHY_ID_KSZ9021,
-	.phy_id_mask	= 0x000fff10,
+	.phy_id_mask	= 0x000ffffe,
 	.name		= "Micrel KSZ9021 Gigabit PHY",
 	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
@@ -240,8 +240,8 @@ MODULE_AUTHOR("David J. Choi");
 MODULE_LICENSE("GPL");
 
 static struct mdio_device_id __maybe_unused micrel_tbl[] = {
-	{ PHY_ID_KSZ9021, 0x000fff10 },
-	{ PHY_ID_KS8001, 0x00fffff0 },
+	{ PHY_ID_KSZ9021, 0x000ffffe },
+	{ PHY_ID_KS8001, 0x00ffffff },
 	{ PHY_ID_KS8737, 0x00fffff0 },
 	{ PHY_ID_KS8041, 0x00fffff0 },
 	{ PHY_ID_KS8051, 0x00fffff0 },
-- 
1.7.6
