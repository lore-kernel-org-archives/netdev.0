From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH 5/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu,  2 Jun 2011 12:38:17 +0300
Message-ID: <56828d7f2670b3782fea89cbc849d526ca3df8d7.1307006502.git.mika.westerberg@iki.fi>
References: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
Cc: linux-arm-kernel@lists.infradead.org, kernel@wantstofly.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	Mika Westerberg <mika.westerberg@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47618 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933050Ab1FBJkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 05:40:40 -0400
Received: by mail-ey0-f174.google.com with SMTP id 24so218562eyx.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 02:40:40 -0700 (PDT)
In-Reply-To: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
In-Reply-To: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
References: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the driver is now passing platform device to the DMA mapping functions,
we should give it valid DMA masks.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
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

