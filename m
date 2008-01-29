From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH] bfin_mac: Make the MDIO polling faster
Date: Wed, 30 Jan 2008 01:47:55 +0800
Message-ID: <1201628875.26902.14.camel@roc-laptop>
References: <Pine.LNX.4.64.0801291427300.7503@pc-213-140-179-32.aina.net>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
To: Kalle Pokki <kalle.pokki@eke.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:37611 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765814AbYA2R6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 12:58:03 -0500
In-Reply-To: <Pine.LNX.4.64.0801291427300.7503@pc-213-140-179-32.aina.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-01-29 at 20:28 +0800, Kalle Pokki wrote:
> The poll routine always got 10 ms penalty when called immediately 
> after starting the transfer. The MDIO transfer takes 25.6 us at the 
> noinal 2.5 MHz, so MAX_TIMEOUT_CNT being 500 is still big enough. 

Exactly, but we got a same fixing already.
It will be sent out soon.

Thanks a lot
-Bryan

> --- 
>  drivers/net/bfin_mac.c |    2 +- 
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c 
> index c199633..d2e6813 100644 
> --- a/drivers/net/bfin_mac.c 
> +++ b/drivers/net/bfin_mac.c 
> @@ -296,7 +296,7 @@ static void mdio_poll(void) 
>   
>         /* poll the STABUSY bit */ 
>         while ((bfin_read_EMAC_STAADD()) & STABUSY) { 
> -               mdelay(10); 
> +               udelay(1); 
>                 if (timeout_cnt-- < 0) { 
>                         printk(KERN_ERR DRV_NAME 
>                         ": wait MDC/MDIO transaction to complete
> timeout\n"); 
> -- 
> 1.4.4.2
> 
