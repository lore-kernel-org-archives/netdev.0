From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/3][v2] net: qcom/emac: do not reset the EMAC during initialization
Date: Fri, 23 Jun 2017 14:33:29 -0500
Message-ID: <1498246410-29794-3-git-send-email-timur@codeaurora.org>
References: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50284 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754672AbdFWTdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 15:33:35 -0400
In-Reply-To: <1498246410-29794-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ACPI systems, the driver depends on firmware pre-initializing the
EMAC because we don't have access to the clocks, and the EMAC has specific
clock programming requirements.  Therefore, we don't want to reset the
EMAC while we are completing the initialization.

Tested-by: Richard Ruigrok <rruigrok@codeaurora.org>
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
v2: improve the patch description.

 drivers/net/ethernet/qualcomm/emac/emac.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 77c5c92..746d94e 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -683,8 +683,6 @@ static int emac_probe(struct platform_device *pdev)
 		goto err_undo_mdiobus;
 	}
 
-	emac_mac_reset(adpt);
-
 	/* set hw features */
 	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
 			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_RX |
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
