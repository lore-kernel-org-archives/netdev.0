From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Sun, 25 Jul 2010 21:57:39 -0700 (PDT)
Message-ID: <20100725.215739.183063953.davem@davemloft.net>
References: <AANLkTi=pSkOuiFGAK4inPdm-KbLuVrz51e2T6eV51ts0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=pSkOuiFGAK4inPdm-KbLuVrz51e2T6eV51ts0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Date: Wed, 21 Jul 2010 14:51:48 -0400

> Subject: [patch] usbnet: fix 100% CPU use on suspended device
> From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> This patch causes the usbnet module not to attempt to submit URBs to the device
> if the device is not ready to accept them. This fixes a misbehavior trigged by
> the Qualcomm Gobi driver (released under GPL through their Code Aurora
> initiative) which causes the usbnet core to consume 100% of CPU attempting and
> failing to submit URBs. This patch is against Linus's 2.6 repo commit
> a9f7f2e74ae0e6a801a2433dc8e9124d73da0cb4.
> Signed-off-by: Elizabeth Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

If the Qualcomm Gobi driver is the only one where this happens, maybe the
real problem is in that driver.

I'm not applying this until a USB person looks more deeply into this.

> ---
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 81c76ad..df7e72e 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1172,6 +1172,7 @@ static void usbnet_bh (unsigned long param)
>  	// or are we maybe short a few urbs?
>  	} else if (netif_running (dev->net) &&
>  		   netif_device_present (dev->net) &&
> +		   dev->udev->can_submit &&
>  		   !timer_pending (&dev->delay) &&
>  		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
>  		int	temp = dev->rxq.qlen;
> --
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
