From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tulip: napi full quantum bug
Date: Sun, 16 Dec 2007 13:40:59 -0800 (PST)
Message-ID: <20071216.134059.239467197.davem@davemloft.net>
References: <20071207161435.42ae67f8@freepuppy.rosehill>
	<1dd3c7c0712080344q414fe7c3w32d7ca6d900a52b5@mail.gmail.com>
	<20071213093545.436b8f8e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristjan.ugrin@gmail.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759580AbXLPVlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:41:12 -0500
In-Reply-To: <20071213093545.436b8f8e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 13 Dec 2007 09:35:45 -0800

> This should fix the kernel warn/oops reported while routing.
> 
> The tulip driver has a fencepost bug with new NAPI in 2.6.24
> It has an off by one bug if a full quantum is reached.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>

Jeff, please apply if you haven't already.

> --- a/drivers/net/tulip/interrupt.c	2007-12-13 09:20:27.000000000 -0800
> +++ b/drivers/net/tulip/interrupt.c	2007-12-13 09:23:34.000000000 -0800
> @@ -151,7 +151,8 @@ int tulip_poll(struct napi_struct *napi,
>                         if (tulip_debug > 5)
>                                 printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
>                                        dev->name, entry, status);
> -		       if (work_done++ >= budget)
> +
> +		       if (++work_done >= budget)
>                                 goto not_done;
>  
>                         if ((status & 0x38008300) != 0x0300) {
