From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 2/2] net: stmmac: add fixed_phy support via fixed-link DT binding
Date: Fri, 23 Jan 2015 15:48:25 +0800
Message-ID: <1421999305-19267-3-git-send-email-ming.lei@canonical.com>
References: <1421999305-19267-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ming Lei <ming.lei@canonical.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1421999305-19267-1-git-send-email-ming.lei@canonical.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 3039de2..73a3ced 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -27,6 +27,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 
 #include "stmmac.h"
 #include "stmmac_platform.h"
@@ -216,6 +217,15 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		plat->pmt = 1;
 	}
 
+	if (of_phy_is_fixed_link(np)) {
+		int ret = of_phy_register_fixed_link(np);
+		if (ret) {
+			dev_err(&pdev->dev, "failed to register fixed PHY\n");
+			return ret;
+		}
+		plat->phy_bus_name = "fixed";
+	}
+
 	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
 		of_device_is_compatible(np, "snps,dwmac-3.710")) {
 		plat->enh_desc = 1;
-- 
1.7.9.5
