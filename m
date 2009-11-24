From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/17] sfc: SFT9001: Reset LED configuration correctly
	after blinking
Date: Tue, 24 Nov 2009 02:02:49 +0000
Message-ID: <1259028169.14645.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34631 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757796AbZKXCCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:02:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 390b27b..19c78d2 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -83,9 +83,9 @@
 #define PMA_PMD_LED_FLASH	(3)
 #define PMA_PMD_LED_MASK	3
 /* All LEDs under hardware control */
-#define PMA_PMD_LED_FULL_AUTO	(0)
+#define SFT9001_PMA_PMD_LED_DEFAULT 0
 /* Green and Amber under hardware control, Red off */
-#define PMA_PMD_LED_DEFAULT	(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
+#define SFX7101_PMA_PMD_LED_DEFAULT (PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
 
 #define PMA_PMD_SPEED_ENABLE_REG 49192
 #define PMA_PMD_100TX_ADV_LBN    1
@@ -291,7 +291,7 @@ static int tenxpress_init(struct efx_nic *efx)
 		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG,
 				  1 << PMA_PMA_LED_ACTIVITY_LBN, true);
 		efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG,
-			       PMA_PMD_LED_DEFAULT);
+			       SFX7101_PMA_PMD_LED_DEFAULT);
 	}
 
 	return 0;
@@ -624,7 +624,10 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 			(PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN) |
 			(PMA_PMD_LED_FLASH << PMA_PMD_LED_LINK_LBN);
 	else
-		reg = PMA_PMD_LED_DEFAULT;
+		if (efx->phy_type == PHY_TYPE_SFX7101)
+			reg = SFX7101_PMA_PMD_LED_DEFAULT;
+		else
+			reg = SFT9001_PMA_PMD_LED_DEFAULT;
 
 	efx_mdio_write(efx, MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG, reg);
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

