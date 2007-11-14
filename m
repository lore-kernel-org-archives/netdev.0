From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH]iwlwifi not correctly dealing with hotunplug
Date: Wed, 14 Nov 2007 09:30:54 +0800
Message-ID: <1195003854.3250.120.camel@debian.sh.intel.com>
References: <200711131926.53732.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"John W.Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200711131926.53732.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-11-13 at 19:26 +0100, Oliver Neukum wrote:
> It makes no sense to enable interrupts if a device has been unplugged.
> In addition if in doubt IRQ_HANDLED should be returned.
> 
> Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

ACK. Could you also do the same for iwl4965? Or John, do you mind to
get the full patch from our GIT (with a little directory twick for the
filename in the patch).

http://intellinuxwireless.org/repos/?p=iwlwifi.git;a=commitdiff_plain;h=96f1d448523930a04b3c81067c1cfafe56cc3768;hp=2355f9930372953d41ee884ea6bf1535d0b09099

Thanks,
-yi

> ----
> 
> --- linux-2.6.24-rc1/drivers/net/wireless/iwlwifi/iwl3945-base.c.alt	2007-11-13 12:23:07.000000000 +0100
> +++ linux-2.6.24-rc1/drivers/net/wireless/iwlwifi/iwl3945-base.c	2007-11-13 12:26:00.000000000 +0100
> @@ -4850,7 +4850,7 @@ static irqreturn_t iwl_isr(int irq, void
>  	if ((inta == 0xFFFFFFFF) || ((inta & 0xFFFFFFF0) == 0xa5a5a5a0)) {
>  		/* Hardware disappeared */
>  		IWL_WARNING("HARDWARE GONE?? INTA == 0x%080x\n", inta);
> -		goto none;
> +		goto unplugged;
>  	}
>  
>  	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
> @@ -4858,6 +4858,7 @@ static irqreturn_t iwl_isr(int irq, void
>  
>  	/* iwl_irq_tasklet() will service interrupts and re-enable them */
>  	tasklet_schedule(&priv->irq_tasklet);
> +unplugged:
>  	spin_unlock(&priv->lock);
>  
>  	return IRQ_HANDLED;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
