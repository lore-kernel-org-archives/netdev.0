From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32: fix user visible typo
Date: Mon, 28 Aug 2006 16:51:42 -0700
Message-ID: <20060828235142.GA6633@us.ibm.com>
References: <20060828233248.GA5193@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:21699 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964903AbWH1XvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:51:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SNp3rw011448
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 19:51:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SNp3RU278368
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 19:51:03 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SNp2dS027678
	for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 19:51:03 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060828233248.GA5193@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cause of #6428 has already been fixed in v1.32 of the pcnet32
driver.  To be correct, the printk should be:

		printk(KERN_INFO PFX "%d card%s found\n",
			cards_found, cards_found != 1 ? "s" : "");

So that zero cards also says 'pcnet32: 0 cards found.'
Why delete the period from the end of the sentence?

On Tue, Aug 29, 2006 at 03:32:49AM +0400, Alexey Dobriyan wrote:
> Also, final dot removed and single form fixed. The cause of #6428 is
> still to be found.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/pcnet32.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -2986,7 +2986,8 @@ static int __init pcnet32_init_module(vo
>  		pcnet32_probe_vlbus(pcnet32_portlist);
>  
>  	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
> -		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
> +		printk(KERN_INFO PFX "%d card%s found\n",
> +			cards_found, cards_found > 1 ? "s" : "");
>  
>  	return (pcnet32_have_pci + cards_found) ? 0 : -ENODEV;
>  }
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Don Fry
brazilnut@us.ibm.com
