From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 04/10] bnx2x: Fix BCM578x0-SFI pre-emphasis settings
Date: Wed, 4 Apr 2012 14:28:57 +0300
Message-ID: <1333538942-9904-5-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2063 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755930Ab2DDJ3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:35 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 578x0-SFI pre-emphasis settings per HW recommendations to achieve better
link strength.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index ce0b0c2..1e2fea3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3994,13 +3994,13 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 
 	} else {
 		misc1_val |= 0x9;
-		tap_val = ((0x12 << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) |
-			   (0x2d << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) |
-			   (0x00 << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET));
+		tap_val = ((0x0f << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) |
+			   (0x2b << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) |
+			   (0x02 << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET));
 		tx_driver_val =
-		      ((0x02 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
+		      ((0x03 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
 		       (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-		       (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET));
+		       (0x06 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET));
 	}
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_SERDESDIGITAL_MISC1, misc1_val);
-- 
1.7.7.1
