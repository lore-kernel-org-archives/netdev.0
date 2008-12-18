From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch]startup race in hso driver
Date: Thu, 18 Dec 2008 14:59:04 +0100
Message-ID: <494A5728.9070908@option.com>
References: <200812181457.36340.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200812181457.36340.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks Oliver,
I'll add it to our internal tree.

Oliver Neukum wrote:
> The flag marking a device running must be set before the URBs for
> recption are submitted or they may complete too early and fail to resubmit.
> 
> Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> 
> 	Regards
> 		Oliver
> 
> ---
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 8e90891..cc75c8b 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -658,10 +658,9 @@ static int hso_net_open(struct net_device *net)
>  	odev->rx_buf_missing = sizeof(struct iphdr);
>  	spin_unlock_irqrestore(&odev->net_lock, flags);
>  
> -	hso_start_net_device(odev->parent);
> -
>  	/* We are up and running. */
>  	set_bit(HSO_NET_RUNNING, &odev->flags);
> +	hso_start_net_device(odev->parent);
>  
>  	/* Tell the kernel we are ready to start receiving from it */
>  	netif_start_queue(net);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
Mobile Ireland: +353-86-1715438
Mobile Belgium  +32-496-226190
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
barrow_dj-/E1597aS9LQAvxtiuMwx3w@public.gmane.org
www.option.com
www.travelsmart.ie

Disclaimer:
http://www.option.com/company/disclaimer.shtml
 RPR Leuven 0429.375.448
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
