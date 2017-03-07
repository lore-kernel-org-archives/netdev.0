From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next] net: stmicro: replace kzalloc with devm_kzalloc
Date: Tue,  7 Mar 2017 15:27:36 +0000
Message-ID: <4e6c083db31dc7a6991401d9d045d3cd89d069b1.1488900195.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:54702 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756581AbdCHACB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 19:02:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The axi variable was not being freed upon device removal.
With devm_kzalloc it ensures that it is properly freed.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 433a842..0ba1caf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -108,7 +108,7 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 	if (!np)
 		return NULL;
 
-	axi = kzalloc(sizeof(*axi), GFP_KERNEL);
+	axi = devm_kzalloc(&pdev->dev, sizeof(*axi), GFP_KERNEL);
 	if (!axi) {
 		of_node_put(np);
 		return ERR_PTR(-ENOMEM);
-- 
2.9.3
