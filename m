From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: lpc_eth: remove irq > NR_IRQS check from probe()
Date: Wed,  2 Dec 2015 08:12:13 +0200
Message-ID: <1449036733-20632-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mleia.com ([178.79.152.223]:41418 "EHLO mail.mleia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932375AbbLBGM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 01:12:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver is used on an ARM platform with SPARSE_IRQ defined,
semantics of NR_IRQS is different (minimal value of virtual irqs) and
by default it is set to 16, see arch/arm/include/asm/irq.h.

This value may be less than the actual number of virtual irqs, which
may break the driver initialization. The check removal allows to use
the driver on such a platform, and, if irq controller driver works
correctly, the check is not needed on legacy platforms.

Fixes a runtime problem:

    lpc-eth 31060000.ethernet: error getting resources.
    lpc_eth: lpc-eth: not found (-6).

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index b159ef8..0576651 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1326,7 +1326,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	/* Get platform resources */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	irq = platform_get_irq(pdev, 0);
-	if ((!res) || (irq < 0) || (irq >= NR_IRQS)) {
+	if (!res || irq < 0) {
 		dev_err(&pdev->dev, "error getting resources.\n");
 		ret = -ENXIO;
 		goto err_exit;
-- 
2.1.4
