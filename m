From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800
 driver
Date: Fri, 05 Feb 2016 15:22:11 +0100
Message-ID: <56B4B013.5030407@laposte.net>
References: <56B4A445.7080402@laposte.net>	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net> <yw1xoabvgs7s.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xoabvgs7s.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
  drivers/net/ethernet/aurora/nb8800.c | 14 +++++++++++++-
  1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c 
b/drivers/net/ethernet/aurora/nb8800.c
index ecc4a33..e1fb071 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1460,7 +1460,19 @@ static int nb8800_probe(struct platform_device *pdev)
  		goto err_disable_clk;
  	}

-	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	if (of_phy_is_fixed_link(pdev->dev.of_node)) {
+		ret = of_phy_register_fixed_link(pdev->dev.of_node);
+		if (ret < 0) {
+			dev_err(&pdev->dev, "bad fixed-link spec\n");
+			goto err_free_bus;
+		}
+		priv->phy_node = of_node_get(pdev->dev.of_node);
+	}
+
+	if (!priv->phy_node)
+		priv->phy_node = of_parse_phandle(pdev->dev.of_node,
+						  "phy-handle", 0);
+
  	if (!priv->phy_node) {
  		dev_err(&pdev->dev, "no PHY specified\n");
  		ret = -ENODEV;
-- 
2.1.4
