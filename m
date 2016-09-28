From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/3] [v2] net: qcom/emac: use device_get_mac_address
Date: Wed, 28 Sep 2016 11:58:43 -0500
Message-ID: <1475081924-12362-3-git-send-email-timur@codeaurora.org>
References: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, linaro-acpi@lists.linaro.org,
        linux-arm-kernel@lists.infradead.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53644 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933044AbcI1Q6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:58:50 -0400
In-Reply-To: <1475081924-12362-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the DT-specific of_get_mac_address() function with
device_get_mac_address, which works on both DT and ACPI platforms.  This
change makes it easier to add ACPI support.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 429b4cb..551df1c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -531,18 +531,16 @@ static void emac_clks_teardown(struct emac_adapter *adpt)
 static int emac_probe_resources(struct platform_device *pdev,
 				struct emac_adapter *adpt)
 {
-	struct device_node *node = pdev->dev.of_node;
 	struct net_device *netdev = adpt->netdev;
 	struct resource *res;
-	const void *maddr;
+	char maddr[ETH_ALEN];
 	int ret = 0;
 
 	/* get mac address */
-	maddr = of_get_mac_address(node);
-	if (!maddr)
-		eth_hw_addr_random(netdev);
-	else
+	if (device_get_mac_address(&pdev->dev, maddr, ETH_ALEN))
 		ether_addr_copy(netdev->dev_addr, maddr);
+	else
+		eth_hw_addr_random(netdev);
 
 	/* Core 0 interrupt */
 	ret = platform_get_irq(pdev, 0);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
