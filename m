From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 1/5] net: fec: reset phy after pinctrl setup
Date: Wed, 27 Jun 2012 21:45:20 +0800
Message-ID: <1340804724-29410-2-git-send-email-shawn.guo@linaro.org>
References: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Florian Fainelli <florian@openwrt.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:18300
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564Ab2F0Np2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 09:45:28 -0400
In-Reply-To: <1340804724-29410-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case that bootloader or platform initialization does not set up
fec pins, the fec_reset_phy will not be able to succeed, because
fec_reset_phy is currently called before devm_pinctrl_get_select_default.
Move fec_reset_phy call to the place between devm_pinctrl_get_select_default
and fec_enet_init to have above case be taken care.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ff7f4c5..e868a37 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1593,8 +1593,6 @@ fec_probe(struct platform_device *pdev)
 		fep->phy_interface = ret;
 	}
 
-	fec_reset_phy(pdev);
-
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
 		irq = platform_get_irq(pdev, i);
 		if (irq < 0) {
@@ -1634,6 +1632,8 @@ fec_probe(struct platform_device *pdev)
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
 
+	fec_reset_phy(pdev);
+
 	ret = fec_enet_init(ndev);
 	if (ret)
 		goto failed_init;
-- 
1.7.5.4
