From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH 01/51] DMA-API: provide a helper to set both DMA and
 coherent DMA masks
Date: Fri, 20 Sep 2013 02:21:37 +0100
Message-ID: <1379640097.2500.4.camel@bwh-desktop.uk.level5networks.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
	 <E1VMlja-0007fA-HU@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
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
	"Solarflare linux maintainers" <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Dan
To: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1VMlja-0007fA-HU-eh5Bv4kxaXIANfyc6IWni62ZND6+EDdj@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-19 at 22:25 +0100, Russell King wrote:
> Provide a helper to set both the DMA and coherent DMA masks to the
> same value - this avoids duplicated code in a number of drivers,
> sometimes with buggy error handling, and also allows us identify
> which drivers do things differently.
> 
> Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> ---
>  Documentation/DMA-API-HOWTO.txt |   37 ++++++++++++++++++++++---------------
>  Documentation/DMA-API.txt       |    8 ++++++++
>  include/linux/dma-mapping.h     |   14 ++++++++++++++
>  3 files changed, 44 insertions(+), 15 deletions(-)
> 
> diff --git a/Documentation/DMA-API-HOWTO.txt b/Documentation/DMA-API-HOWTO.txt
> index 14129f1..5e98303 100644
> --- a/Documentation/DMA-API-HOWTO.txt
> +++ b/Documentation/DMA-API-HOWTO.txt
[...]
> -dma_set_coherent_mask() will always be able to set the same or a
> -smaller mask as dma_set_mask(). However for the rare case that a
> +The coherent coherent mask will always be able to set the same or a
> +smaller mask as the streaming mask. However for the rare case that a
[...]

The new wording doesn't make sense; a mask doesn't set itself.  I would
suggest:

"The coherent mask can always be set to the same or a smaller mask than
the streaming mask."

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
