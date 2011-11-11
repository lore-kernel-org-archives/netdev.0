From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH V3 03/14] ARM: mxc: ahci: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 18:50:26 +0800
Message-ID: <1321008637-19999-4-git-send-email-richard.zhao@linaro.org>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	<kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>, <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	<alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, <eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1321008637-19999-1-git-send-email-richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 arch/arm/plat-mxc/devices/platform-ahci-imx.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/arm/plat-mxc/devices/platform-ahci-imx.c b/arch/arm/plat-mxc/devices/platform-ahci-imx.c
index d8a56ae..ade4a1c 100644
--- a/arch/arm/plat-mxc/devices/platform-ahci-imx.c
+++ b/arch/arm/plat-mxc/devices/platform-ahci-imx.c
@@ -60,9 +60,9 @@ static int imx_sata_init(struct device *dev, void __iomem *addr)
 		dev_err(dev, "no sata clock.\n");
 		return PTR_ERR(sata_clk);
 	}
-	ret = clk_enable(sata_clk);
+	ret = clk_prepare_enable(sata_clk);
 	if (ret) {
-		dev_err(dev, "can't enable sata clock.\n");
+		dev_err(dev, "can't prepare/enable sata clock.\n");
 		goto put_sata_clk;
 	}
 
@@ -73,9 +73,9 @@ static int imx_sata_init(struct device *dev, void __iomem *addr)
 		ret = PTR_ERR(sata_ref_clk);
 		goto release_sata_clk;
 	}
-	ret = clk_enable(sata_ref_clk);
+	ret = clk_prepare_enable(sata_ref_clk);
 	if (ret) {
-		dev_err(dev, "can't enable sata ref clock.\n");
+		dev_err(dev, "can't prepare/enable sata ref clock.\n");
 		goto put_sata_ref_clk;
 	}
 
@@ -104,11 +104,11 @@ static int imx_sata_init(struct device *dev, void __iomem *addr)
 	return 0;
 
 release_sata_ref_clk:
-	clk_disable(sata_ref_clk);
+	clk_disable_unprepare(sata_ref_clk);
 put_sata_ref_clk:
 	clk_put(sata_ref_clk);
 release_sata_clk:
-	clk_disable(sata_clk);
+	clk_disable_unprepare(sata_clk);
 put_sata_clk:
 	clk_put(sata_clk);
 
@@ -117,10 +117,10 @@ put_sata_clk:
 
 static void imx_sata_exit(struct device *dev)
 {
-	clk_disable(sata_ref_clk);
+	clk_disable_unprepare(sata_ref_clk);
 	clk_put(sata_ref_clk);
 
-	clk_disable(sata_clk);
+	clk_disable_unprepare(sata_clk);
 	clk_put(sata_clk);
 
 }
-- 
1.7.5.4
