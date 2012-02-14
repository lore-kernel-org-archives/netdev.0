From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] 3c59x: shorten timer period for slave devices
Date: Tue, 14 Feb 2012 14:51:10 -0600
Message-ID: <1329252670.3054.85.camel@dcbw.foobar.com>
References: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201202141350.57657.jdelvare@suse.de> <20120214133418.GJ32155@v3-1054>
	 <20120214.144335.558771219791311889.davem@davemloft.net>
	 <1329251229.2555.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, jdelvare@suse.de,
	fubar@us.ibm.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760766Ab2BNUuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 15:50:14 -0500
In-Reply-To: <1329251229.2555.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-14 at 21:27 +0100, Eric Dumazet wrote:
> Jean Delvare reported bonding on top of 3c59x adapters was not detecting
> network cable removal fast enough.
> 
> 3c59x indeed uses a 60 seconds timer to check link status if carrier is
> on, and 5 seconds if carrier is off.
> 
> This patch reduces timer period to 5 seconds if device is a bonding
> slave.

Maybe for posterity give some rationale as to why we feel we can reduce
it to 5 seconds for slaves instead of reducing the timer period in
general?  If you weren't party to this discussion that won't be apparent
from the commit log.

Dan

> Reported-by: Jean Delvare <jdelvare@suse.de>
> Acked-by: Jean Delvare <jdelvare@suse.de>
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  drivers/net/ethernet/3com/3c59x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
> index 1282f04..e463d10 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
>  		ok = 1;
>  	}
>  
> -	if (!netif_carrier_ok(dev))
> +	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
>  		next_tick = 5*HZ;
>  
>  	if (vp->medialock)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
