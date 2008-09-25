From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gianfar: Fix error in mdio reset timeout
Date: Wed, 24 Sep 2008 20:50:16 -0400
Message-ID: <48DAE048.5020508@garzik.org>
References: <1222103036-27770-1-git-send-email-tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47044 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752721AbYIYAuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:50:20 -0400
In-Reply-To: <1222103036-27770-1-git-send-email-tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trent Piepho wrote:
> The loop with the timeout used "while (...  && timeout--)", which means
> than when the timeout occurs, "timeout" will be -1 after the loop has
> exited.  The code that checks if the looped exited because of a timeout
> used "if (timeout <= 0)".  Seems ok, except timeout is unsigned, and
> (unsigned)-1 isn't less than zero!
> 
> Using "--timeout" in the loop fixes this problem, as now "timeout" will be
> 0 when the loop times out.
> 
> This also fixes a bug in the existing code, where it will erroneously think
> a timeout occurred if the condition the loop was waiting for is satisfied
> on the final iteration before a timeout.
> 
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar_mii.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
> index ebcfb27..906aba2 100644
> --- a/drivers/net/gianfar_mii.c
> +++ b/drivers/net/gianfar_mii.c
> @@ -136,12 +136,12 @@ static int gfar_mdio_reset(struct mii_bus *bus)
>  
>  	/* Wait until the bus is free */
>  	while ((gfar_read(&regs->miimind) & MIIMIND_BUSY) &&
> -			timeout--)
> +			--timeout)
>  		cpu_relax();
>  
>  	mutex_unlock(&bus->mdio_lock);
>  
> -	if(timeout <= 0) {
> +	if(timeout == 0) {
>  		printk(KERN_ERR "%s: The MII Bus is stuck!\n",

applied


