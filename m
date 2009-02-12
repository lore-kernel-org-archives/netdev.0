From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 28/41]bnx2x: Using nvram default WoL config
Date: Thu, 12 Feb 2009 20:37:52 +0200
Message-ID: <1234463872.1863.160.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758229AbZBLSiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 28/41]bnx2x: Using nvram default WoL config
The driver default WoL setting is set to the nvram default value

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2e95799..a14fe75 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8027,6 +8027,12 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		bp->link_params.feature_config_flags &=
 				~FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED;
 
+	/* If the device is capable of WoL, set the default state according
+	 * to the HW
+	 */
+	bp->wol = (!(bp->flags & NO_WOL_FLAG) &&
+		   (config & PORT_FEATURE_WOL_ENABLED));
+
 	BNX2X_DEV_INFO("lane_config 0x%08x  ext_phy_config 0x%08x"
 		       "  speed_cap_mask 0x%08x  link_config 0x%08x\n",
 		       bp->link_params.lane_config,
-- 
1.5.4.3




