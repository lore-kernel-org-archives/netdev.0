From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net v2 2/6] bnx2x: Enable FEC for 57810-KR
Date: Wed, 7 Sep 2011 13:47:54 +0300
Message-ID: <1315392474.27750.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4573 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755969Ab1IGQMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable FEC(Forward Error Correction) for 57810-KR to reduce link errors.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    6 ++++++
 drivers/net/bnx2x/bnx2x_reg.h  |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 9d381db..f7a7ac3 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3624,6 +3624,12 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 			 MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT1, val16);
 
+	/* Advertised and set FEC (Forward Error Correction) */
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+			 MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT2,
+			 (MDIO_WC_REG_AN_IEEE1BLK_AN_ADV2_FEC_ABILITY |
+			  MDIO_WC_REG_AN_IEEE1BLK_AN_ADV2_FEC_REQ));
+
 	/* Enable CL37 BAM */
 	if (REG_RD(bp, params->shmem_base +
 		   offsetof(struct shmem_region, dev_info.
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 40266c1..2bfedde 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6853,6 +6853,9 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_WC_REG_IEEE0BLK_AUTONEGNP			0x7
 #define MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT0	0x10
 #define MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT1	0x11
+#define MDIO_WC_REG_AN_IEEE1BLK_AN_ADVERTISEMENT2	0x12
+#define MDIO_WC_REG_AN_IEEE1BLK_AN_ADV2_FEC_ABILITY	0x4000
+#define MDIO_WC_REG_AN_IEEE1BLK_AN_ADV2_FEC_REQ		0x8000
 #define MDIO_WC_REG_PMD_IEEE9BLK_TENGBASE_KR_PMD_CONTROL_REGISTER_150  0x96
 #define MDIO_WC_REG_XGXSBLK0_XGXSCONTROL		0x8000
 #define MDIO_WC_REG_XGXSBLK0_MISCCONTROL1		0x800e
-- 
1.7.1
