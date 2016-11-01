From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 1/2] net: qcom/emac: configure the external phy to allow pause frames
Date: Tue,  1 Nov 2016 13:30:54 -0500
Message-ID: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37316 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbcKASbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:31:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pause frames are used to enable flow control.  A MAC can send and
receive pause frames in order to throttle traffic.  However, the PHY
must be configured to allow those frames to pass through.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 6fb3bee..70a55dc 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -1003,6 +1003,12 @@ int emac_mac_up(struct emac_adapter *adpt)
 	writel((u32)~DIS_INT, adpt->base + EMAC_INT_STATUS);
 	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
 
+	/* Enable pause frames.  Without this feature, the EMAC has been shown
+	 * to receive (and drop) frames with FCS errors at gigabit connections.
+	 */
+	adpt->phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	adpt->phydev->advertising |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
 	adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
 	phy_start(adpt->phydev);
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
