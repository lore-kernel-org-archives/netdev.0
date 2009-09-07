From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Mon, 7 Sep 2009 12:24:34 +0200
Message-ID: <20090907102434.GC31592@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de> <20090826104634.GA14425@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51791 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbZIGKYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 06:24:32 -0400
Content-Disposition: inline
In-Reply-To: <20090826104634.GA14425@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kurt,

On Wed, Aug 26, 2009 at 12:46:34PM +0200, Kurt Van Dijck wrote:
> Hi Sacha,
> 
> I'm using a 2.6.25.
> Converting to your platform_device based driver,
> I needed to configure the irq (see patch, irq flags).
> Looking in the old cs89x0.c, it's done in the driver. Should I have
> configured the irq level elsewhere? Or is this patch valid to do?

This is the way to go. I don't know if the cs89x0 has configurable
interrupt levels though.

Sascha

> 
> Kurt
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> ---
> Index: drivers/net/cirrus-cs89x0.c
> ===================================================================
> --- drivers/net/cirrus-cs89x0.c	(revision 7107)
> +++ drivers/net/cirrus-cs89x0.c	(working copy)
> @@ -487,7 +487,8 @@
>         }
>  
>         /* install interrupt handler */
> -       result = request_irq(ndev->irq, &cirrus_interrupt, 0, ndev->name, ndev);
> +       result = request_irq(ndev->irq, &cirrus_interrupt,
> +			IRQF_TRIGGER_HIGH, ndev->name, ndev);
>         if (result < 0) {
>                 printk(KERN_ERR "%s: could not register interrupt %d\n",
>                        ndev->name, ndev->irq);
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
