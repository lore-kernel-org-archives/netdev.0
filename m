From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V3 14/14] mmc: sdhci-esdhc-imx: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 18:50:37 +0800
Message-ID: <1321008637-19999-15-git-send-email-richard.zhao@linaro.org>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@arm.linux.org.uk>, <amit.kucheria@canonical.com>,
	<kernel@pengutronix.de>, <ben-linux@fluff.org>, <cjb@laptop.org>,
	<alan@linux.intel.com>, <eric.miao@linaro.org>,
	Richard Zhao <richard.zhao@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>,
	<linux-i2c@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-serial@vger.kernel.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 drivers/mmc/host/sdhci-esdhc-imx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/mmc/host/sdhci-esdhc-imx.c b/drivers/mmc/host/sdhci-esdhc-imx.c
index ae57769..f1ae37e 100644
--- a/drivers/mmc/host/sdhci-esdhc-imx.c
+++ b/drivers/mmc/host/sdhci-esdhc-imx.c
@@ -462,7 +462,7 @@ static int __devinit sdhci_esdhc_imx_probe(struct platform_device *pdev)
 		err = PTR_ERR(clk);
 		goto err_clk_get;
 	}
-	clk_enable(clk);
+	clk_prepare_enable(clk);
 	pltfm_host->clk = clk;
 
 	if (!is_imx25_esdhc(imx_data))
@@ -550,7 +550,7 @@ no_card_detect_irq:
 		gpio_free(boarddata->wp_gpio);
 no_card_detect_pin:
 no_board_data:
-	clk_disable(pltfm_host->clk);
+	clk_disable_unprepare(pltfm_host->clk);
 	clk_put(pltfm_host->clk);
 err_clk_get:
 	kfree(imx_data);
@@ -577,7 +577,7 @@ static int __devexit sdhci_esdhc_imx_remove(struct platform_device *pdev)
 		gpio_free(boarddata->cd_gpio);
 	}
 
-	clk_disable(pltfm_host->clk);
+	clk_disable_unprepare(pltfm_host->clk);
 	clk_put(pltfm_host->clk);
 	kfree(imx_data);
 
-- 
1.7.5.4


