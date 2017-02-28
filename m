From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: qcom/emac: optimize QDF2400 SGMII RX/TX impedence values
Date: Tue, 28 Feb 2017 17:16:02 -0600
Message-ID: <1488323762-15195-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53312 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdB1XlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 18:41:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust the impedance values of the RX and TX lanes in the SGMII block
so that they are closer to optimal values.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
index f62c215..7116be4 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
@@ -26,6 +26,7 @@
 
 /* SGMII digital lane registers */
 #define EMAC_SGMII_LN_DRVR_CTRL0		0x000C
+#define EMAC_SGMII_LN_DRVR_CTRL1		0x0010
 #define EMAC_SGMII_LN_DRVR_TAP_EN		0x0018
 #define EMAC_SGMII_LN_TX_MARGINING		0x001C
 #define EMAC_SGMII_LN_TX_PRE			0x0020
@@ -48,6 +49,7 @@
 #define EMAC_SGMII_LN_RX_EN_SIGNAL		0x02AC
 #define EMAC_SGMII_LN_RX_MISC_CNTRL0		0x02B8
 #define EMAC_SGMII_LN_DRVR_LOGIC_CLKDIV		0x02C8
+#define EMAC_SGMII_LN_RX_RESECODE_OFFSET	0x02CC
 
 /* SGMII digital lane register values */
 #define UCDR_STEP_BY_TWO_MODE0			BIT(7)
@@ -73,6 +75,8 @@
 #define CML_GEAR_MODE(x)			(((x) & 7) << 3)
 #define CML2CMOS_IBOOST_MODE(x)			((x) & 7)
 
+#define RESCODE_OFFSET(x)			((x) & 0x1f)
+
 #define MIXER_LOADB_MODE(x)			(((x) & 0xf) << 2)
 #define MIXER_DATARATE_MODE(x)			((x) & 3)
 
@@ -159,6 +163,8 @@ static void emac_reg_write_all(void __iomem *base,
 	{EMAC_SGMII_LN_PARALLEL_RATE, PARALLEL_RATE_MODE0(1)},
 	{EMAC_SGMII_LN_TX_BAND_MODE, BAND_MODE0(1)},
 	{EMAC_SGMII_LN_RX_BAND, BAND_MODE0(2)},
+	{EMAC_SGMII_LN_DRVR_CTRL1, RESCODE_OFFSET(7)},
+	{EMAC_SGMII_LN_RX_RESECODE_OFFSET, RESCODE_OFFSET(9)},
 	{EMAC_SGMII_LN_LANE_MODE, LANE_MODE(26)},
 	{EMAC_SGMII_LN_RX_RCVR_PATH1_MODE0, CDR_PD_SEL_MODE0(2) |
 		EN_DLL_MODE0 | EN_IQ_DCC_MODE0 | EN_IQCAL_MODE0},
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
