From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/4] net: qcom/emac: remove unused address arrays
Date: Wed, 11 Oct 2017 14:52:24 -0500
Message-ID: <1507751546-10265-3-git-send-email-timur@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37624 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752691AbdJKTwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:52:32 -0400
In-Reply-To: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC is capable of multiple TX and RX rings, but the driver only
supports one ring for each.  One function had some left-over unused
code that supports multiple rings, but all it did was make the code
harder to read.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 3ed9033e56db..9cbb27263742 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -309,22 +309,12 @@ void emac_mac_mode_config(struct emac_adapter *adpt)
 /* Config descriptor rings */
 static void emac_mac_dma_rings_config(struct emac_adapter *adpt)
 {
-	static const unsigned short tpd_q_offset[] = {
-		EMAC_DESC_CTRL_8,        EMAC_H1TPD_BASE_ADDR_LO,
-		EMAC_H2TPD_BASE_ADDR_LO, EMAC_H3TPD_BASE_ADDR_LO};
-	static const unsigned short rfd_q_offset[] = {
-		EMAC_DESC_CTRL_2,        EMAC_DESC_CTRL_10,
-		EMAC_DESC_CTRL_12,       EMAC_DESC_CTRL_13};
-	static const unsigned short rrd_q_offset[] = {
-		EMAC_DESC_CTRL_5,        EMAC_DESC_CTRL_14,
-		EMAC_DESC_CTRL_15,       EMAC_DESC_CTRL_16};
-
 	/* TPD (Transmit Packet Descriptor) */
 	writel(upper_32_bits(adpt->tx_q.tpd.dma_addr),
 	       adpt->base + EMAC_DESC_CTRL_1);
 
 	writel(lower_32_bits(adpt->tx_q.tpd.dma_addr),
-	       adpt->base + tpd_q_offset[0]);
+	       adpt->base + EMAC_DESC_CTRL_8);
 
 	writel(adpt->tx_q.tpd.count & TPD_RING_SIZE_BMSK,
 	       adpt->base + EMAC_DESC_CTRL_9);
@@ -334,9 +324,9 @@ static void emac_mac_dma_rings_config(struct emac_adapter *adpt)
 	       adpt->base + EMAC_DESC_CTRL_0);
 
 	writel(lower_32_bits(adpt->rx_q.rfd.dma_addr),
-	       adpt->base + rfd_q_offset[0]);
+	       adpt->base + EMAC_DESC_CTRL_2);
 	writel(lower_32_bits(adpt->rx_q.rrd.dma_addr),
-	       adpt->base + rrd_q_offset[0]);
+	       adpt->base + EMAC_DESC_CTRL_5);
 
 	writel(adpt->rx_q.rfd.count & RFD_RING_SIZE_BMSK,
 	       adpt->base + EMAC_DESC_CTRL_3);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
