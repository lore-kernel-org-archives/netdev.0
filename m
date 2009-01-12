From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch]startup race in hso driver
Date: Mon, 12 Jan 2009 11:03:02 +0100
Message-ID: <496B1556.3010901@option.com>
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

Hi Oliver,
Is the patch below now obselete?
I applied it to our internal tree, should I remove it?

I've yet to check the code in the big patch with subject
Re: another race in hso
Does this patch render the small one below obselete?



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
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
