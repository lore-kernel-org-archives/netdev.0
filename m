From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 4/5] [net-next] net: qcom/emac: remove extraneous wake-on-lan code
Date: Fri, 27 Jan 2017 16:43:47 -0600
Message-ID: <1485557028-32510-6-git-send-email-timur@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57212 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdA0Wzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:35 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC driver does not support wake-on-lan, but there is still
code left-over that partially enables it.  Remove that code and a few
macros that support it.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 10 ----------
 drivers/net/ethernet/qualcomm/emac/emac.h     |  4 ----
 2 files changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 3f3cd00..33d7ff1 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -103,14 +103,6 @@
 #define RXEN                            0x00000002
 #define TXEN                            0x00000001
 
-
-/* EMAC_WOL_CTRL0 */
-#define LK_CHG_PME			0x20
-#define LK_CHG_EN			0x10
-#define MG_FRAME_PME			0x8
-#define MG_FRAME_EN			0x4
-#define WK_FRAME_EN			0x1
-
 /* EMAC_DESC_CTRL_3 */
 #define RFD_RING_SIZE_BMSK                                       0xfff
 
@@ -619,8 +611,6 @@ static void emac_mac_start(struct emac_adapter *adpt)
 
 	emac_reg_update32(adpt->base + EMAC_ATHR_HEADER_CTRL,
 			  (HEADER_ENABLE | HEADER_CNT_EN), 0);
-
-	emac_reg_update32(adpt->csr + EMAC_EMAC_WRAPPER_CSR2, 0, WOL_EN);
 }
 
 void emac_mac_stop(struct emac_adapter *adpt)
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
index 2725507..ef91dcc 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -167,10 +167,6 @@ enum emac_clk_id {
 
 #define EMAC_MAX_SETUP_LNK_CYCLE                                   100
 
-/* Wake On Lan */
-#define EMAC_WOL_PHY                     0x00000001 /* PHY Status Change */
-#define EMAC_WOL_MAGIC                   0x00000002 /* Magic Packet */
-
 struct emac_stats {
 	/* rx */
 	u64 rx_ok;              /* good packets */
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
