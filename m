From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] stmmac: fix check for phydev being open
Date: Mon,  7 Sep 2015 21:15:09 +0300
Message-ID: <1441649709-12325-1-git-send-email-abrodkin@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:33624 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbIGSPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 14:15:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation via IS_ERR(phydev) may make no sense because
of_phy_attach() returns NULL on failure instead of error value.

Still for checking result of phy_connect() IS_ERR() is useful.

So adding explicit check for NULL.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: arc-linux-dev@synopsys.com
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 864b476..ad2ce3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -837,7 +837,7 @@ static int stmmac_init_phy(struct net_device *dev)
 				     interface);
 	}
 
-	if (IS_ERR(phydev)) {
+	if (!phydev || IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
 	}
-- 
2.4.3
