From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 2/5] net: ep93xx_eth: pass struct device to DMA API
 functions
Date: Thu, 9 Jun 2011 18:40:21 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B8699@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <c0ddfc297e0ea1e64e58cedd6552c6b2e52c5fe8.1307040443.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>
To: Mika Westerberg <mika.westerberg@iki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail131.messagelabs.com ([216.82.242.99]:19357 "EHLO
	mail131.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398Ab1FIXkc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 19:40:32 -0400
In-Reply-To: <c0ddfc297e0ea1e64e58cedd6552c6b2e52c5fe8.1307040443.git.mika.westerberg@iki.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
>
> We shouldn't use NULL for any DMA API functions, unless we are dealing with
> ISA or EISA device. So pass correct struct dev pointer to these functions.
>
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/net/arm/ep93xx_eth.c |   26 ++++++++++++++++----------
>  1 files changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
> index 5a77001..8779d3b 100644
> --- a/drivers/net/arm/ep93xx_eth.c
> +++ b/drivers/net/arm/ep93xx_eth.c
> @@ -159,6 +159,8 @@ struct ep93xx_priv
>  	void __iomem		*base_addr;
>  	int			irq;
>  
> +	struct device		*dma_dev;

Mika,

I just noticed this macro in include/linux/netdevice.h

/* Set the sysfs physical device reference for the network logical device
 * if set prior to registration will cause a symlink during initialization.
 */
#define SET_NETDEV_DEV(net, pdev)       ((net)->dev.parent = (pdev))

Is there anyway you could use that macro in the probe to save the platform_device
(with it's associated device) instead of introducing a new struct device * in the
private data?

Regards,
Hartley