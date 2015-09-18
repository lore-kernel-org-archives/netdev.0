From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH] Revert "net/phy: Add Vitesse 8641 phy ID"
Date: Fri, 18 Sep 2015 15:42:30 +0800
Message-ID: <1442562150-19720-1-git-send-email-haokexin@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35385 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbbIRHmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 03:42:44 -0400
Received: by ykdu9 with SMTP id u9so39625061ykd.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 00:42:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 1298267b548a78840bd4b3e030993ff8747ca5e6.

That commit claim that the Vitesse VSC8641 is compatible with Vitesse
82xx. But this is not true. It seems that all the registers used
in Vitesse phy driver are not compatible between 8641 and 82xx.
It does cause malfunction of the Ethernet on p1010rdb-pa board.
So we definitely need a rework in order to support the 8641 phy
in this driver.

Signed-off-by: Kevin Hao <haokexin@gmail.com>
---
 drivers/net/phy/vitesse.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 17cad185169d..76cad712ddb2 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -66,7 +66,6 @@
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8514			0x00070670
 #define PHY_ID_VSC8574			0x000704a0
-#define PHY_ID_VSC8641			0x00070431
 #define PHY_ID_VSC8662			0x00070660
 #define PHY_ID_VSC8221			0x000fc550
 #define PHY_ID_VSC8211			0x000fc4b0
@@ -273,18 +272,6 @@ static struct phy_driver vsc82xx_driver[] = {
 	.config_intr    = &vsc82xx_config_intr,
 	.driver         = { .owner = THIS_MODULE,},
 }, {
-	.phy_id         = PHY_ID_VSC8641,
-	.name           = "Vitesse VSC8641",
-	.phy_id_mask    = 0x000ffff0,
-	.features       = PHY_GBIT_FEATURES,
-	.flags          = PHY_HAS_INTERRUPT,
-	.config_init    = &vsc824x_config_init,
-	.config_aneg    = &vsc82x4_config_aneg,
-	.read_status    = &genphy_read_status,
-	.ack_interrupt  = &vsc824x_ack_interrupt,
-	.config_intr    = &vsc82xx_config_intr,
-	.driver         = { .owner = THIS_MODULE,},
-}, {
 	.phy_id         = PHY_ID_VSC8662,
 	.name           = "Vitesse VSC8662",
 	.phy_id_mask    = 0x000ffff0,
@@ -331,7 +318,6 @@ static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8514, 0x000ffff0 },
 	{ PHY_ID_VSC8574, 0x000ffff0 },
-	{ PHY_ID_VSC8641, 0x000ffff0 },
 	{ PHY_ID_VSC8662, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ PHY_ID_VSC8211, 0x000ffff0 },
-- 
2.4.3
