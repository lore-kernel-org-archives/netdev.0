From: Mark Brown <broonie@kernel.org>
Subject: [PATCH 1/2] net: fsl: Don't use NO_IRQ to check return value of irq_of_parse_and_map()
Date: Thu, 26 Nov 2015 11:59:45 +0000
Message-ID: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Cc: netdev@vger.kernel.org, Mark Brown <broonie@kernel.org>
To: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:49683 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbKZMAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:00:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver can be built on arm64 but relies on NO_IRQ to check the return
value of irq_of_parse_and_map() which fails to build on arm64 because the
architecture does not provide a NO_IRQ. Fix this to correctly check the
return value of irq_of_parse_and_map().

Even on ARM systems where the driver was previously used the check was
broken since on ARM NO_IRQ is -1 but irq_of_parse_and_map() returns 0 on
error.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/ethernet/freescale/gianfar.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 67b1850c034e..4ce60e0c8341 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -647,9 +647,9 @@ static int gfar_parse_group(struct device_node *np,
 	if (model && strcasecmp(model, "FEC")) {
 		gfar_irq(grp, RX)->irq = irq_of_parse_and_map(np, 1);
 		gfar_irq(grp, ER)->irq = irq_of_parse_and_map(np, 2);
-		if (gfar_irq(grp, TX)->irq == NO_IRQ ||
-		    gfar_irq(grp, RX)->irq == NO_IRQ ||
-		    gfar_irq(grp, ER)->irq == NO_IRQ)
+		if (!gfar_irq(grp, TX)->irq ||
+		    !gfar_irq(grp, RX)->irq ||
+		    !gfar_irq(grp, ER)->irq)
 			return -EINVAL;
 	}
 
-- 
2.6.2
