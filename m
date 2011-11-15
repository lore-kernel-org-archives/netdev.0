From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V4 03/14] ARM: mxc: ahci: add clk_prepare/clk_unprepare
Date: Tue, 15 Nov 2011 14:47:58 +0800
Message-ID: <1321339689-25256-4-git-send-email-richard.zhao@linaro.org>
References: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amit.kucheria@canonical.com, linux@arm.linux.org.uk, kernel@pengutronix.de,
 eric.miao@linaro.org, ben-linux@fluff.org, cjb@laptop.org,
 richard.zhao@linaro.org, alan@linux.intel.com
To: <linux-arm-kernel@lists.infradead.org>, <linux-i2c@vger.kernel.org>,
 <linux-mmc@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-serial@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1321339689-25256-1-git-send-email-richard.zhao@linaro.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

It's for migrating to generic clk framework API.

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
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
