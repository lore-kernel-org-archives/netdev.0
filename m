From: Mark Brown <broonie@kernel.org>
Subject: [PATCH 2/2] net: fsl: Fix error checking for platform_get_irq()
Date: Thu, 26 Nov 2015 11:59:46 +0000
Message-ID: <1448539186-5756-2-git-send-email-broonie@kernel.org>
References: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Cc: netdev@vger.kernel.org, Mark Brown <broonie@kernel.org>
To: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:49684 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbKZMAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:00:02 -0500
In-Reply-To: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gianfar driver has recently been enabled on arm64 but fails to build
since it check the return value of platform_get_irq() against NO_IRQ. Fix
this by instead checking for a negative error code.

Even on ARM where this code was previously being built this check was
incorrect since platform_get_irq() returns a negative error code which
may not be exactly the (unsigned int)(-1) that NO_IRQ is defined to be.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 664d0c261269..b40fba929d65 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -467,7 +467,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 
 	etsects->irq = platform_get_irq(dev, 0);
 
-	if (etsects->irq == NO_IRQ) {
+	if (etsects->irq < 0) {
 		pr_err("irq not in device tree\n");
 		goto no_node;
 	}
-- 
2.6.2
