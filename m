From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 37/51] DMA-API: usb: use new dma_coerce_mask_and_coherent()
Date: Mon, 23 Sep 2013 14:34:34 +0200
Message-ID: <5240355A.9010609@atmel.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk> <E1VMmIV-0007jw-Gq@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Kukjin Kim <kgene.kim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Tony Prisk <linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
To: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	<alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	<e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	<linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1VMmIV-0007jw-Gq-eh5Bv4kxaXIANfyc6IWni62ZND6+EDdj@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/09/2013 00:02, Russell King :
> Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> ---
>   drivers/usb/chipidea/ci_hdrc_imx.c |    4 +---
>   drivers/usb/dwc3/dwc3-exynos.c     |    4 +---
>   drivers/usb/host/ehci-atmel.c      |    4 +---

For Atmel driver:

Acked-by: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>

[..]

> diff --git a/drivers/usb/host/ehci-atmel.c b/drivers/usb/host/ehci-atmel.c
> index 5831a88..8e7323e 100644
> --- a/drivers/usb/host/ehci-atmel.c
> +++ b/drivers/usb/host/ehci-atmel.c
> @@ -90,9 +90,7 @@ static int ehci_atmel_drv_probe(struct platform_device *pdev)
>   	 * Since shared usb code relies on it, set it here for now.
>   	 * Once we have dma capability bindings this can go away.
>   	 */
> -	if (!pdev->dev.dma_mask)
> -		pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
> -	retval = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	retval = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>   	if (retval)
>   		goto fail_create_hcd;
>

[..]

Thanks Russell,
-- 
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
