From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/2] [v2] net: qcom/emac: enable flow control if requested
Date: Mon,  7 Nov 2016 10:51:41 -0600
Message-ID: <1478537501-23454-3-git-send-email-timur@codeaurora.org>
References: <1478537501-23454-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, alokc@codeaurora.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46182 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcKGQvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:51:47 -0500
In-Reply-To: <1478537501-23454-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PHY has been configured to allow pause frames, then the MAC
should be configured to generate and/or accept those frames.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

v2: fix calculation when TXFC should be set

 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 70a55dc..0b4deb3 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -575,10 +575,11 @@ void emac_mac_start(struct emac_adapter *adpt)
 
 	mac |= TXEN | RXEN;     /* enable RX/TX */
 
-	/* We don't have ethtool support yet, so force flow-control mode
-	 * to 'full' always.
-	 */
-	mac |= TXFC | RXFC;
+	/* Configure MAC flow control to match the PHY's settings. */
+	if (phydev->pause)
+		mac |= RXFC;
+	if (phydev->pause != phydev->asym_pause)
+		mac |= TXFC;
 
 	/* setup link speed */
 	mac &= ~SPEED_MASK;
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
