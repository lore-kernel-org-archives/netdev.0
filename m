From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Ensure local assignment bit on tun device MAC addr
Date: Fri, 30 Mar 2007 21:03:40 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703302103180.29590@d.namei>
References: <1175302152.12230.414.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:55502 "EHLO
	mail3.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933234AbXCaBDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 21:03:44 -0400
In-Reply-To: <1175302152.12230.414.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 31 Mar 2007, Rusty Russell wrote:

> This becomes especially important after the tun patch sitting in the -mm
> tree is applied, but it works standalone.  Please apply.  (See netdev
> posting Message-Id: <200703270550.l2R5o0Mh008378@shell0.pdx.osdl.net>)
> 
> ==
> The effect of this bug was made worse by Brian Braunstein's patch to keep
> net_device.dev_addr and tun.dev_addr in sync.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: James Morris <jmorris@namei.org>

> 
> diff -r fd8c40f4f533 drivers/net/tun.c
> --- a/drivers/net/tun.c	Fri Mar 30 17:02:19 2007 +1000
> +++ b/drivers/net/tun.c	Sat Mar 31 10:30:47 2007 +1000
> @@ -507,9 +507,7 @@ static int tun_set_iff(struct file *file
>  		tun->flags = flags;
>  		/* Be promiscuous by default to maintain previous behaviour. */
>  		tun->if_flags = IFF_PROMISC;
> -		/* Generate random Ethernet address. */
> -		*(u16 *)tun->dev_addr = htons(0x00FF);
> -		get_random_bytes(tun->dev_addr + sizeof(u16), 4);
> +		random_ether_addr(tun->dev_addr);
>  		memset(tun->chr_filter, 0, sizeof tun->chr_filter);
>  
>  		tun_net_init(dev);
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
