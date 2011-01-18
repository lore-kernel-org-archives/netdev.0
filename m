From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 6/8] bnx2x: Fix BCM84823 LED behavior
Date: Tue, 18 Jan 2011 16:33:47 +0200
Message-ID: <1295361227.5281.89.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3540 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab1AROdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:33:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix BCM84823 LED behavior which may show on some systems

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   18 +++++++++++++++++-
 drivers/net/bnx2x/bnx2x_reg.h  |    4 ++++
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index f5fd33e..bb1c811 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -5972,10 +5972,26 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 			 MDIO_PMA_REG_8481_LED2_MASK,
 			 0x18);
 
+	/* Select activity source by Tx and Rx, as suggested by PHY AE */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LED3_MASK,
-			 0x0040);
+			 0x0006);
+
+	/* Select the closest activity blink rate to that in 10/100/1000 */
+	bnx2x_cl45_write(bp, phy,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8481_LED3_BLINK,
+			0);
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_84823_CTL_LED_CTL_1, &val);
+	val |= MDIO_PMA_REG_84823_LED3_STRETCH_EN; /* stretch_en for LED3*/
+
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_84823_CTL_LED_CTL_1, val);
 
 	/* 'Interrupt Mask' */
 	bnx2x_cl45_write(bp, phy,
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 38ef7ca..73efc9b 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6194,7 +6194,11 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_CTL_REG_84823_MEDIA_PRIORITY_COPPER	0x0000
 #define MDIO_CTL_REG_84823_MEDIA_PRIORITY_FIBER		0x0100
 #define MDIO_CTL_REG_84823_MEDIA_FIBER_1G			0x1000
+#define MDIO_CTL_REG_84823_USER_CTRL_REG		0x4005
+#define MDIO_CTL_REG_84823_USER_CTRL_CMS		0x0080
 
+#define MDIO_PMA_REG_84823_CTL_LED_CTL_1		0xa8e3
+#define MDIO_PMA_REG_84823_LED3_STRETCH_EN		0x0080
 
 #define IGU_FUNC_BASE			0x0400
 
-- 
1.7.1








