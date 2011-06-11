From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH v3 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Sat, 11 Jun 2011 21:39:54 +0300
Message-ID: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, hsweeten@visionengravers.com,
	rmallon@gmail.com, davem@davemloft.net, ynezz@true.cz,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47303 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab1FKSmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 14:42:36 -0400
Received: by eyx24 with SMTP id 24so1226264eyx.19
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2011 11:42:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the driver uses the DMA API, we should pass it valid DMA masks.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Tested-by: Petr Stetiar <ynezz@true.cz>
---
 arch/arm/mach-ep93xx/core.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-ep93xx/core.c b/arch/arm/mach-ep93xx/core.c
index 8207954..1d4b65f 100644
--- a/arch/arm/mach-ep93xx/core.c
+++ b/arch/arm/mach-ep93xx/core.c
@@ -402,11 +402,15 @@ static struct resource ep93xx_eth_resource[] = {
 	}
 };
 
+static u64 ep93xx_eth_dma_mask = DMA_BIT_MASK(32);
+
 static struct platform_device ep93xx_eth_device = {
 	.name		= "ep93xx-eth",
 	.id		= -1,
 	.dev		= {
-		.platform_data	= &ep93xx_eth_data,
+		.platform_data		= &ep93xx_eth_data,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
+		.dma_mask		= &ep93xx_eth_dma_mask,
 	},
 	.num_resources	= ARRAY_SIZE(ep93xx_eth_resource),
 	.resource	= ep93xx_eth_resource,
-- 
1.7.4.4

