From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH]iwlwifi not correctly dealing with hotunplug
Date: Tue, 13 Nov 2007 10:37:03 -0500
Message-ID: <1194968223.2955.33.camel@localhost.localdomain>
References: <200711131249.25320.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbXKMPpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 10:45:05 -0500
In-Reply-To: <200711131249.25320.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-13 at 12:49 +0100, Oliver Neukum wrote:
> It makes no sense to enable interrupts if a device has been unplugged.
> In addition if in doubt IRQ_HANDLED should be returned.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Might want to forward to linux-wireless@ ?  And maybe cc the ipw2100@
sourceforge upstream lists too.

Dan

> 	Regards
> 		Oliver
> 
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
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

