From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 13/51] DMA-API: net: sfc/efx.c: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Fri, 20 Sep 2013 14:55:28 +0100
Message-ID: <1379685328.1681.0.camel@bwh-desktop.uk.level5networks.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
	 <E1VMlvE-0007gc-B5@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23287 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784Ab3ITNzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 09:55:35 -0400
In-Reply-To: <E1VMlvE-0007gc-B5@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Trimmed cc's]

On Thu, 2013-09-19 at 22:38 +0100, Russell King wrote:
> Replace the following sequence:
> 
> 	dma_set_mask(dev, mask);
> 	dma_set_coherent_mask(dev, mask);
> 
> with a call to the new helper dma_set_mask_and_coherent().
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/efx.c |   12 +-----------
>  1 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 07c9bc4..2e27837 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -1121,7 +1121,7 @@ static int efx_init_io(struct efx_nic *efx)
>  	 */
>  	while (dma_mask > 0x7fffffffUL) {
>  		if (dma_supported(&pci_dev->dev, dma_mask)) {
> -			rc = dma_set_mask(&pci_dev->dev, dma_mask);
> +			rc = dma_set_mask_and_coherent(&pci_dev->dev, dma_mask);
>  			if (rc == 0)
>  				break;
>  		}
> @@ -1134,16 +1134,6 @@ static int efx_init_io(struct efx_nic *efx)
>  	}
>  	netif_dbg(efx, probe, efx->net_dev,
>  		  "using DMA mask %llx\n", (unsigned long long) dma_mask);
> -	rc = dma_set_coherent_mask(&pci_dev->dev, dma_mask);
> -	if (rc) {
> -		/* dma_set_coherent_mask() is not *allowed* to
> -		 * fail with a mask that dma_set_mask() accepted,
> -		 * but just in case...
> -		 */
> -		netif_err(efx, probe, efx->net_dev,
> -			  "failed to set consistent DMA mask\n");
> -		goto fail2;
> -	}
>  
>  	efx->membase_phys = pci_resource_start(efx->pci_dev, EFX_MEM_BAR);
>  	rc = pci_request_region(pci_dev, EFX_MEM_BAR, "sfc");

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
