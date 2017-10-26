From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net] net: stmmac: First Queue must always be in DCB mode
Date: Thu, 26 Oct 2017 10:07:12 +0100
Message-ID: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:56684 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdJZJH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 05:07:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to DWMAC databook the first queue operating mode
must always be in DCB.

As MTL_QUEUE_DCB = 1, we need to always set the first queue
operating mode to DCB otherwise driver will think that queue
is in AVB mode (because MTL_QUEUE_AVB = 0).

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 21f59fe..603225b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -150,6 +150,13 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 	plat->rx_queues_to_use = 1;
 	plat->tx_queues_to_use = 1;
 
+	/* First Queue must always be in DCB mode. As MTL_QUEUE_DCB = 1 we need
+	 * to always set this, otherwise Queue will be classified as AVB
+	 * (because MTL_QUEUE_AVB = 0).
+	 */
+	plat->rx_queues_cfg[0].mode_to_use = MTL_QUEUE_DCB;
+	plat->tx_queues_cfg[0].mode_to_use = MTL_QUEUE_DCB;
+
 	rx_node = of_parse_phandle(pdev->dev.of_node, "snps,mtl-rx-config", 0);
 	if (!rx_node)
 		return;
-- 
1.9.1
