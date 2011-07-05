From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 3/8] bnx2x: Add CL37 BAM for Warpcore
Date: Tue, 5 Jul 2011 14:06:41 +0300
Message-ID: <1309864001.4050.82.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3865 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755879Ab1GELGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CL37 BAM support according to configuration.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   14 +++++++++++++-
 drivers/net/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 011548a..270a2f7 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3564,7 +3564,7 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 					struct link_params *params,
 					struct link_vars *vars) {
-	u16 val16 = 0, lane;
+	u16 val16 = 0, lane, bam37 = 0;
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "Enable Auto Negotiation for KR\n");
 	/* Check adding advertisement for 1G KX */
@@ -3616,6 +3616,18 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 			 MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT1, val16);
 
+	/* Enable CL37 BAM */
+	if (REG_RD(bp, params->shmem_base +
+		   offsetof(struct shmem_region, dev_info.
+			    port_hw_config[params->port].default_cfg)) &
+	    PORT_HW_CFG_ENABLE_BAM_ON_KR_ENABLED) {
+		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
+				MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL, &bam37);
+		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+			MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL, bam37 | 1);
+		DP(NETIF_MSG_LINK, "Enable CL37 BAM on KR\n");
+	}
+
 	/* Advertise pause */
 	bnx2x_ext_phy_set_pause(params, phy, vars);
 
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 1684e1b..c97ce37 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6889,6 +6889,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_WC_REG_DIGITAL5_MISC6			0x8345
 #define MDIO_WC_REG_DIGITAL5_MISC7			0x8349
 #define MDIO_WC_REG_DIGITAL5_ACTUAL_SPEED		0x834e
+#define MDIO_WC_REG_DIGITAL6_MP5_NEXTPAGECTRL		0x8350
 #define MDIO_WC_REG_CL49_USERB0_CTRL			0x8368
 #define MDIO_WC_REG_TX66_CONTROL			0x83b0
 #define MDIO_WC_REG_RX66_CONTROL			0x83c0
-- 
1.7.1







