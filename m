From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH] net: davinci_emac: Add support for fixed-link PHY
Date: Tue, 22 Sep 2015 10:57:04 +0200
Message-ID: <560117E0.20307@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case the DaVinci Emac is directly connected to a
non-mdio PHY/device, it should be possible to provide
a fixed link configuration in the DT.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index aeebc0a..6521dfb 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1861,8 +1861,12 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	pdata->no_bd_ram = of_property_read_bool(np, "ti,davinci-no-bd-ram");

 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
-	if (!priv->phy_node)
-		pdata->phy_id = NULL;
+	if (!priv->phy_node) {
+		if (!of_phy_is_fixed_link(np))
+			pdata->phy_id = NULL;
+		else if (of_phy_register_fixed_link(np) >= 0)
+			priv->phy_node = of_node_get(np);
+	}

 	auxdata = pdev->dev.platform_data;
 	if (auxdata) {
-- 
1.9.1
