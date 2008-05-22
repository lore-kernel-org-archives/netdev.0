From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] au1000_eth: remove useless check
Date: Thu, 22 May 2008 06:22:22 -0400
Message-ID: <4835495E.8020506@pobox.com>
References: <Pine.LNX.4.64.0805121537320.3694@ask.diku.dk> <20080512161734.GA22190@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0805121852510.16384@ask.diku.dk> <20080512164421.GB22190@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia@diku.dk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59353 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934948AbYEVKW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:22:27 -0400
In-Reply-To: <20080512164421.GB22190@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> The lifespan of the device covers the request_irq .. free_irq interval.
> 
> The cast of a void * pointer is not needed either.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index 3634b5f..7023d77 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -1239,12 +1239,7 @@ static int au1000_rx(struct net_device *dev)
>   */
>  static irqreturn_t au1000_interrupt(int irq, void *dev_id)
>  {
> -	struct net_device *dev = (struct net_device *) dev_id;
> -
> -	if (dev == NULL) {
> -		printk(KERN_ERR "%s: isr: null dev ptr\n", dev->name);
> -		return IRQ_RETVAL(1);
> -	}
> +	struct net_device *dev = dev_id;
>  

applied


