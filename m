From: Mauro Carvalho Chehab <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 19/51] DMA-API: media: dt3155v4l: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Thu, 31 Oct 2013 09:46:40 -0200
Message-ID: <20131031094640.205840a2@samsung.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMm13-0007hO-9l@rmk-PC.arm.linux.org.uk> <5249673B.5020705@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
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
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Russell King <rmk+kernel@ar
To: Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <5249673B.5020705-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Russell,

Em Mon, 30 Sep 2013 13:57:47 +0200
Hans Verkuil <hverkuil-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org> escreveu:

> On 09/19/2013 11:44 PM, Russell King wrote:
> > Replace the following sequence:
> > 
> > 	dma_set_mask(dev, mask);
> > 	dma_set_coherent_mask(dev, mask);
> > 
> > with a call to the new helper dma_set_mask_and_coherent().
> > 
> > Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> 
> Acked-by: Hans Verkuil <hans.verkuil-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>

Somehow, I lost your original post (I got unsubscribed on a few days 
from all vger mailing lists at the end of september).

I suspect that you want to sent this via your tree, right?
If so:

Acked-by: Mauro Carvalho Chehab <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

> 
> Regards,
> 
> 	Hans
> 
> > ---
> >  drivers/staging/media/dt3155v4l/dt3155v4l.c |    5 +----
> >  1 files changed, 1 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/staging/media/dt3155v4l/dt3155v4l.c b/drivers/staging/media/dt3155v4l/dt3155v4l.c
> > index 90d6ac4..081407b 100644
> > --- a/drivers/staging/media/dt3155v4l/dt3155v4l.c
> > +++ b/drivers/staging/media/dt3155v4l/dt3155v4l.c
> > @@ -901,10 +901,7 @@ dt3155_probe(struct pci_dev *pdev, const struct pci_device_id *id)
> >  	int err;
> >  	struct dt3155_priv *pd;
> >  
> > -	err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
> > -	if (err)
> > -		return -ENODEV;
> > -	err = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> > +	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
> >  	if (err)
> >  		return -ENODEV;
> >  	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 

Cheers,
Mauro
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
