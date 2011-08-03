From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 06/10] bnx2x: Fix link issue with DAC over 578xx
Date: Wed, 3 Aug 2011 11:59:47 +0300
Message-ID: <1312361987.21665.96.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab1HCJAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix no-link issue on BCM578xx when direct attached cable is connected since Warpcore microcode restart was missing to re-read the new mode. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index d8f6eff..6a3fdf8 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -8029,6 +8029,9 @@ static void bnx2x_warpcore_set_limiting_mode(struct link_params *params,
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 			MDIO_WC_REG_UC_INFO_B1_FIRMWARE_MODE, &val);
 
+	/* Restart microcode to re-read the new mode */
+	bnx2x_warpcore_reset_lane(bp, phy, 1);
+	bnx2x_warpcore_reset_lane(bp, phy, 0);
 
 }
 
-- 
1.7.1








