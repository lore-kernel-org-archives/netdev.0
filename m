From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu,  2 Jun 2011 21:59:34 +0300
Message-ID: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, kernel@wantstofly.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:61050 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab1FBTBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:01:54 -0400
Received: by ewy4 with SMTP id 4so414248ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 12:01:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the driver is now passing platform device to the DMA mapping functions,
we should give it valid DMA masks.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
Changes to previous version are:
	- moved this patch to be first
	- added Russell's acks

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

