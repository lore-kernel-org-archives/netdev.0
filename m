From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 3/4] net: davinci_mdio: drop pinctrl_pm_select_default_state from probe
Date: Fri, 18 Apr 2014 20:24:56 +0300
Message-ID: <1397841897-9170-4-git-send-email-grygorii.strashko@ti.com>
References: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<prabhakar.csengg@gmail.com>, <santosh.shilimkar@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<sergei.shtylyov@cogentembedded.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "default" pinctrl state is set by Drivers core now before
calling the driver's probe.
Hence, it's safe to drop pinctrl_pm_select_default_state() call
from Davinci mdio driver probe.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Cs: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index eda4946..98d53a3 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -348,9 +348,6 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 
-	/* Select default pin state */
-	pinctrl_pm_select_default_state(&pdev->dev);
-
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 	data->clk = devm_clk_get(dev, "fck");
-- 
1.7.9.5
