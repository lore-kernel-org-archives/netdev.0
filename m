From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] Revert "net: qcom/emac: configure the external phy to allow pause frames"
Date: Tue, 17 Jan 2017 16:31:19 -0600
Message-ID: <1484692279-18289-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Alok Chauhan <alokc@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56184 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdAQWb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 17:31:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3e884493448131179a5b7cae1ddca1028ffaecc8.

With commit 529ed1275263 ("net: phy: phy drivers should not set
SUPPORTED_[Asym_]Pause"), phylib now handles automatically enabling
pause frame support in the PHY, and the MAC driver should follow suit.

Since the EMAC driver driver does this,  we no longer need to force
pause frames support.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 0b4deb3..384e1be 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -1004,12 +1004,6 @@ int emac_mac_up(struct emac_adapter *adpt)
 	writel((u32)~DIS_INT, adpt->base + EMAC_INT_STATUS);
 	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
 
-	/* Enable pause frames.  Without this feature, the EMAC has been shown
-	 * to receive (and drop) frames with FCS errors at gigabit connections.
-	 */
-	adpt->phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	adpt->phydev->advertising |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-
 	adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
 	phy_start(adpt->phydev);
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
