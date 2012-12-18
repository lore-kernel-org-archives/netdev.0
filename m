From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH] net: fec: forbid FEC_PTP on SoCs that do not support
Date: Tue, 18 Dec 2012 21:06:44 +0800
Message-ID: <1355836004-22067-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:19889
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752924Ab2LRNGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 08:06:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Beside imx6q, the kernel built from imx_v6_v7_defconfig is also
supposed to be running on other IMX SoCs that do not have the PTP
block.  Before fec driver gets fixed to run-time detect target hardware
rather than conditional compiling with #ifdef CONFIG_FEC_PTP, let's
give it a quick fix in Kconfig to forbid FEC_PTP on those IMX SoCs that
do not support PTP.

Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/Kconfig |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 5ba6e1c..ec490d7 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -94,9 +94,8 @@ config GIANFAR
 
 config FEC_PTP
 	bool "PTP Hardware Clock (PHC)"
-	depends on FEC && ARCH_MXC
+	depends on FEC && ARCH_MXC && !SOC_IMX25 && !SOC_IMX27 && !SOC_IMX35 && !SOC_IMX5
 	select PTP_1588_CLOCK
-	default y if SOC_IMX6Q
 	--help---
 	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
 	  driver.  Only the basic clock operations have been implemented.
-- 
1.7.9.5
