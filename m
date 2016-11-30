From: Neill Whillans <neill.whillans@codethink.co.uk>
Subject: [PATCH 1/2] net: phy: vitesse: add support for VSC8572
Date: Wed, 30 Nov 2016 13:41:04 +0000
Message-ID: <dfabe39a52efcd2cfff9358f271b8673143503b8.1480497966.git.neill.whillans@codethink.co.uk>
References: <cover.1480497966.git.neill.whillans@codethink.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@lists.codethink.co.uk,
        nios2-dev@lists.rocketboards.org, vbridger@opensource.altera.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap0.codethink.co.uk ([185.43.218.159]:43534 "EHLO
        imap0.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754198AbcK3OOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:14:01 -0500
In-Reply-To: <cover.1480497966.git.neill.whillans@codethink.co.uk>
In-Reply-To: <cover.1480497966.git.neill.whillans@codethink.co.uk>
References: <cover.1480497966.git.neill.whillans@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Agate <stephen.agate@uk.thalesgroup.com>

Add support for the Vitesse VSC8572 which is functionally equivalent to
the already supported VSC8574. As such, all the same handling functions
are used since the VSC8572 merely has half the number of phy blocks
internally.

Signed-off-by: Stephen Agate <stephen.agate@uk.thalesgroup.com>
Signed-off-by: Neill Whillans <neill.whillans@codethink.co.uk>
Reviewed-by: Daniel Silverstone <daniel.silverstone@codethink.co.uk>
---
 drivers/net/phy/vitesse.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 24b4a09..f78ff02 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -69,6 +69,7 @@
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8514			0x00070670
+#define PHY_ID_VSC8572			0x000704d0
 #define PHY_ID_VSC8574			0x000704a0
 #define PHY_ID_VSC8601			0x00070420
 #define PHY_ID_VSC8662			0x00070660
@@ -166,6 +167,7 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 			(phydev->drv->phy_id == PHY_ID_VSC8234 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8244 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8514 ||
+			 phydev->drv->phy_id == PHY_ID_VSC8572 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8574 ||
 			 phydev->drv->phy_id == PHY_ID_VSC8601) ?
 				MII_VSC8244_IMASK_MASK :
@@ -291,6 +293,17 @@ static struct phy_driver vsc82xx_driver[] = {
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
 }, {
+	.phy_id         = PHY_ID_VSC8572,
+	.name           = "Vitesse VSC8572",
+	.phy_id_mask    = 0x000ffff0,
+	.features       = PHY_GBIT_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.config_init    = &vsc824x_config_init,
+	.config_aneg    = &vsc82x4_config_aneg,
+	.read_status    = &genphy_read_status,
+	.ack_interrupt  = &vsc824x_ack_interrupt,
+	.config_intr    = &vsc82xx_config_intr,
+}, {
 	.phy_id         = PHY_ID_VSC8574,
 	.name           = "Vitesse VSC8574",
 	.phy_id_mask    = 0x000ffff0,
@@ -355,6 +368,7 @@ static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8234, 0x000ffff0 },
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8514, 0x000ffff0 },
+	{ PHY_ID_VSC8572, 0x000ffff0 },
 	{ PHY_ID_VSC8574, 0x000ffff0 },
 	{ PHY_ID_VSC8662, 0x000ffff0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
-- 
2.1.4
