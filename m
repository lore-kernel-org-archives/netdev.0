From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/2] net: qcom/emac: enable flow control if requested
Date: Tue,  1 Nov 2016 13:30:55 -0500
Message-ID: <1478025055-13167-2-git-send-email-timur@codeaurora.org>
References: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37400 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbcKASbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:31:02 -0400
In-Reply-To: <1478025055-13167-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PHY has been configured to allow pause frames, then the MAC
should be configured to generate and/or accept those frames.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 70a55dc..46e19e9 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -575,10 +575,12 @@ void emac_mac_start(struct emac_adapter *adpt)
 
 	mac |= TXEN | RXEN;     /* enable RX/TX */
 
-	/* We don't have ethtool support yet, so force flow-control mode
-	 * to 'full' always.
-	 */
-	mac |= TXFC | RXFC;
+	/* Configure MAC flow control to patch the PHY's settings */
+	if (phydev->pause)
+		mac |= RXFC;
+
+	if (!phydev->pause && phydev->asym_pause)
+		mac |= TXFC;
 
 	/* setup link speed */
 	mac &= ~SPEED_MASK;
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
