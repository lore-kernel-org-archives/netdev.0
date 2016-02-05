From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Fri, 05 Feb 2016 14:31:49 +0100
Message-ID: <56B4A445.7080402@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
  drivers/net/ethernet/aurora/nb8800.c | 19 +++++++++++++++----
  1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c 
b/drivers/net/ethernet/aurora/nb8800.c
index ecc4a33..1353fee 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1461,10 +1461,21 @@ static int nb8800_probe(struct platform_device 
*pdev)
  	}

  	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
-	if (!priv->phy_node) {
-		dev_err(&pdev->dev, "no PHY specified\n");
-		ret = -ENODEV;
-		goto err_free_bus;
+	if (!priv->phy_node)
+	{
+		if (of_phy_is_fixed_link(pdev->dev.of_node)) {
+			ret = of_phy_register_fixed_link(pdev->dev.of_node);
+			if (ret < 0) {
+				dev_err(&pdev->dev, "broken fixed-link specification\n");
+				goto err_free_bus;
+			}
+			priv->phy_node = of_node_get(pdev->dev.of_node);
+		}
+		else {
+			dev_err(&pdev->dev, "no PHY specified\n");
+			ret = -ENODEV;
+			goto err_free_bus;
+		}
  	}

  	priv->mii_bus = bus;
-- 
2.1.4
