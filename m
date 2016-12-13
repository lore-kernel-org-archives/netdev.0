From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [v2] net: qcom/emac: don't try to claim clocks on ACPI systems
Date: Tue, 13 Dec 2016 17:49:02 -0600
Message-ID: <1481672942-20024-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, Christopher Covington <cov@codeaurora.org>,
        alokc@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57722 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbcLMXuT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 18:50:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ACPI systems, clocks are not available to drivers directly.  They are
handled exclusively by ACPI and/or firmware, so there is no clock driver.
Calls to clk_get() always fail, so we should not even attempt to claim
any clocks on ACPI systems.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

Notes:
    v2: move check into functions

 drivers/net/ethernet/qualcomm/emac/emac.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index ae32f85..422289c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -460,6 +460,12 @@ static int emac_clks_phase1_init(struct platform_device *pdev,
 {
 	int ret;
 
+	/* On ACPI platforms, clocks are controlled by firmware and/or
+	 * ACPI, not by drivers.
+	 */
+	if (has_acpi_companion(&pdev->dev))
+		return 0;
+
 	ret = emac_clks_get(pdev, adpt);
 	if (ret)
 		return ret;
@@ -485,6 +491,9 @@ static int emac_clks_phase2_init(struct platform_device *pdev,
 {
 	int ret;
 
+	if (has_acpi_companion(&pdev->dev))
+		return 0;
+
 	ret = clk_set_rate(adpt->clk[EMAC_CLK_TX], 125000000);
 	if (ret)
 		return ret;
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
