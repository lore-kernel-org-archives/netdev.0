From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 2/5] bnx2x: Fix LED blink rate on BCM84823
Date: Sun, 30 Jan 2011 16:14:55 +0200
Message-ID: <1296396895.10095.51.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1627 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754184Ab1A3ORn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 09:17:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix blink rate of activity LED of the BCM84823 on 10G link

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x_link.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 53a95a2..b1c667a 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -6475,6 +6475,18 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LED1_MASK,
 					 0x80);
+
+			/* Tell LED3 to blink on source */
+			bnx2x_cl45_read(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LINK_SIGNAL,
+					&val);
+			val &= ~(7<<6);
+			val |= (1<<6); /* A83B[8:6]= 1 */
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LINK_SIGNAL,
+					 val);
 		}
 		break;
 	}
-- 
1.7.1








