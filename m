From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 04/14] net: ethernet: ti: cpsw: remove clk var from priv
Date: Sat,  6 Aug 2016 13:48:34 +0300
Message-ID: <1470480524-6851-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to hold link to clk, it's used only once
while probe.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 30e1ddb..70a9570 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -379,7 +379,6 @@ struct cpsw_priv {
 	u32				coal_intvl;
 	u32				bus_freq_mhz;
 	int				rx_packet_max;
-	struct clk			*clk;
 	u8				mac_addr[ETH_ALEN];
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
@@ -2179,8 +2178,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
 	priv_sl2->slaves = priv->slaves;
-	priv_sl2->clk = priv->clk;
-
 	priv_sl2->coal_intvl = 0;
 	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
 
@@ -2258,6 +2255,7 @@ MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
 
 static int cpsw_probe(struct platform_device *pdev)
 {
+	struct clk			*clk;
 	struct cpsw_platform_data	*data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv;
@@ -2336,14 +2334,14 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->slaves[0].ndev = ndev;
 	priv->emac_port = 0;
 
-	priv->clk = devm_clk_get(&pdev->dev, "fck");
-	if (IS_ERR(priv->clk)) {
+	clk = devm_clk_get(&pdev->dev, "fck");
+	if (IS_ERR(clk)) {
 		dev_err(priv->dev, "fck is not found\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
 	priv->coal_intvl = 0;
-	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
+	priv->bus_freq_mhz = clk_get_rate(clk) / 1000000;
 
 	ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
-- 
1.9.1
