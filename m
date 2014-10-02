From: Michael Welling <mwelling@ieee.org>
Subject: [PATCH] drivers:ethernet:davinci_emac.c:Fixes flaw in mac address handling.
Date: Wed,  1 Oct 2014 21:32:05 -0500
Message-ID: <1412217125-11057-1-git-send-email-mwelling@ieee.org>
Cc: Michael Welling <mwelling@ieee.org>
To: davem@davemloft.net, tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code currently checks the mac_addr variable that is clearly
zero'd out during allocation.

Further code is added to bring the mac_addr from the partial pdata.

Signed-off-by: Michael Welling <mwelling@ieee.org>
---
 drivers/net/ethernet/ti/davinci_emac.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index ea71251..e06f97c 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1804,11 +1804,9 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	np = pdev->dev.of_node;
 	pdata->version = EMAC_VERSION_2;
 
-	if (!is_valid_ether_addr(pdata->mac_addr)) {
-		mac_addr = of_get_mac_address(np);
-		if (mac_addr)
-			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
-	}
+	mac_addr = of_get_mac_address(np);
+	if (mac_addr)
+		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
 
 	of_property_read_u32(np, "ti,davinci-ctrl-reg-offset",
 			     &pdata->ctrl_reg_offset);
@@ -1834,6 +1832,8 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	if (auxdata) {
 		pdata->interrupt_enable = auxdata->interrupt_enable;
 		pdata->interrupt_disable = auxdata->interrupt_disable;
+		if (is_valid_ether_addr(auxdata->mac_addr))
+			memcpy(pdata->mac_addr, auxdata->mac_addr, ETH_ALEN);
 	}
 
 	match = of_match_device(davinci_emac_of_match, &pdev->dev);
-- 
1.7.9.5
