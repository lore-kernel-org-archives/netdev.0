From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH 31/51] DMA-API: media: omap3isp: use dma_coerce_mask_and_coherent()
Date: Fri, 27 Sep 2013 03:56:13 +0200
Message-ID: <4110555.qb0XUyFHNE@avalon>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk> <E1VMmCg-0007j1-Pi@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	Mauro Carvalho Chehab <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1VMmCg-0007j1-Pi-eh5Bv4kxaXIANfyc6IWni62ZND6+EDdj@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Russell,

Thank you for the patch.

On Thursday 19 September 2013 22:56:02 Russell King wrote:
> The code sequence:
> 	isp->raw_dmamask = DMA_BIT_MASK(32);
> 	isp->dev->dma_mask = &isp->raw_dmamask;
> 	isp->dev->coherent_dma_mask = DMA_BIT_MASK(32);
> bypasses the architectures check on the DMA mask.  It can be replaced
> with dma_coerce_mask_and_coherent(), avoiding the direct initialization
> of this mask.
> 
> Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>

Acked-by: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>

> ---
>  drivers/media/platform/omap3isp/isp.c |    6 +++---
>  drivers/media/platform/omap3isp/isp.h |    3 ---
>  2 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/media/platform/omap3isp/isp.c
> b/drivers/media/platform/omap3isp/isp.c index df3a0ec..1c36080 100644
> --- a/drivers/media/platform/omap3isp/isp.c
> +++ b/drivers/media/platform/omap3isp/isp.c
> @@ -2182,9 +2182,9 @@ static int isp_probe(struct platform_device *pdev)
>  	isp->pdata = pdata;
>  	isp->ref_count = 0;
> 
> -	isp->raw_dmamask = DMA_BIT_MASK(32);
> -	isp->dev->dma_mask = &isp->raw_dmamask;
> -	isp->dev->coherent_dma_mask = DMA_BIT_MASK(32);
> +	ret = dma_coerce_mask_and_coherent(isp->dev, DMA_BIT_MASK(32));
> +	if (ret)
> +		return ret;
> 
>  	platform_set_drvdata(pdev, isp);
> 
> diff --git a/drivers/media/platform/omap3isp/isp.h
> b/drivers/media/platform/omap3isp/isp.h index cd3eff4..ce65d3a 100644
> --- a/drivers/media/platform/omap3isp/isp.h
> +++ b/drivers/media/platform/omap3isp/isp.h
> @@ -152,7 +152,6 @@ struct isp_xclk {
>   * @mmio_base_phys: Array with physical L4 bus addresses for ISP register
>   *                  regions.
>   * @mmio_size: Array with ISP register regions size in bytes.
> - * @raw_dmamask: Raw DMA mask
>   * @stat_lock: Spinlock for handling statistics
>   * @isp_mutex: Mutex for serializing requests to ISP.
>   * @crashed: Bitmask of crashed entities (indexed by entity ID)
> @@ -190,8 +189,6 @@ struct isp_device {
>  	unsigned long mmio_base_phys[OMAP3_ISP_IOMEM_LAST];
>  	resource_size_t mmio_size[OMAP3_ISP_IOMEM_LAST];
> 
> -	u64 raw_dmamask;
> -
>  	/* ISP Obj */
>  	spinlock_t stat_lock;	/* common lock for statistic drivers */
>  	struct mutex isp_mutex;	/* For handling ref_count field */
-- 
Regards,

Laurent Pinchart

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
