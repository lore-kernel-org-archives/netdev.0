From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu, 9 Jun 2011 23:41:13 +0300
Message-ID: <20110609204113.GE2857@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <ADE657CA350FB648AAC2C43247A983F001F3820B85F3@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55039 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab1FIUnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:43:40 -0400
Received: by eyx24 with SMTP id 24so679554eyx.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 13:43:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F3820B85F3@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 03:27:11PM -0500, H Hartley Sweeten wrote:
> On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
> >
> > As the driver is now passing platform device to the DMA mapping functions,
> > we should give it valid DMA masks.
> >
> > Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> > Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Since you made this patch the first in the series the commit message is not
> quite right.  Other than that:
> 
> Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Ah, right. I forgot to change the commit message. How about following?

From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: [PATCH 1/5] ep93xx: set DMA masks for the ep93xx_eth

Since the driver uses the DMA API, we should pass it valid DMA masks.

Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
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

