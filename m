From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 3/4] ARM: imx6q: Set enet tx reference clk from anatop to support 1588
Date: Wed, 31 Oct 2012 12:25:22 +0800
Message-ID: <1351657522-25756-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznua@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:15945
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328Ab2JaFIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 01:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set GRP1 BIT21 ENET_CLK_SEL:
  Enet tx reference clk from internal clock from anatop
  (loopback through pad), this clock also sent out to external PHY

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 arch/arm/mach-imx/mach-imx6q.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
index 47c91f7..38d6910 100644
--- a/arch/arm/mach-imx/mach-imx6q.c
+++ b/arch/arm/mach-imx/mach-imx6q.c
@@ -117,6 +117,17 @@ static void __init imx6q_sabrelite_init(void)
 	imx6q_sabrelite_cko1_setup();
 }
 
+static void __init imx6q_1588_init(void)
+{
+	struct regmap *gpr;
+
+	gpr = syscon_regmap_lookup_by_compatible("fsl,imx6q-iomuxc-gpr");
+	if (!IS_ERR(gpr))
+		regmap_update_bits(gpr, 0x4, 1 << 21, 1 << 21);
+	else
+		pr_err("failed to find fsl,imx6q-iomux-gpr regmap\n");
+
+}
 static void __init imx6q_usb_init(void)
 {
 	struct regmap *anatop;
@@ -153,6 +164,7 @@ static void __init imx6q_init_machine(void)
 
 	imx6q_pm_init();
 	imx6q_usb_init();
+	imx6q_1588_init();
 }
 
 static struct cpuidle_driver imx6q_cpuidle_driver = {
-- 
1.7.1
