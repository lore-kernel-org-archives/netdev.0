From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 11/18] bnx2x: Enable BCM8726 module transmitter
Date: Mon, 02 Mar 2009 20:00:07 +0200
Message-ID: <1236016807.7723.82.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4812 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755912AbZCBSBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 11/18] bnx2x: Enable BCM8726 module transmitter

When 8726 module detection option is disabled, module should be transmitting
regardless of invalid read from EEPROM

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 35f3b5a..280f008 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2668,11 +2668,7 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 			  params->port);
 
 	/* Check and set limiting mode / LRM mode */
-	if (bnx2x_bcm8726_set_limiting_mode(params, module_type)
-	     != 0) {
-		DP(NETIF_MSG_LINK, "Setting limiting mode failed!!\n");
-		return -EINVAL;
-	}
+	bnx2x_bcm8726_set_limiting_mode(params, module_type);
 
 	/* Enable transmit for this module */
 	bnx2x_bcm8726_set_transmitter(bp, params->port,
-- 
1.5.4.3




