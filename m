From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/6] au1000-eth: fix bad printk usages
Date: Mon, 09 Aug 2010 15:17:21 -0700
Message-ID: <1281392241.1954.39.camel@Joe-Laptop.home>
References: <201008092203.41338.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2333 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754295Ab0HIWRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 18:17:24 -0400
In-Reply-To: <201008092203.41338.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-09 at 22:03 +0200, Florian Fainelli wrote:
> Use pr_(info|err) and pr_cont where required instead of calls to printk.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index 9a0515d..f8f1f5e 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -732,24 +732,25 @@ static int au1000_rx(struct net_device *dev)
>  			netif_rx(skb);	/* pass the packet to upper layers */
>  		} else {
>  			if (au1000_debug > 4) {
> +				pr_err("rx_error: ");

This should be:

				pr_err("rx_error(s):");

>  				if (status & RX_MISSED_FRAME)
> -					printk("rx miss\n");
> +					pr_cont("rx miss\n");

These blocks should be "pr_cont(" value");

with a leading space and without the "\n"

>  				if (status & RX_WDOG_TIMER)
> -					printk("rx wdog\n");
> +					pr_cont("rx wdog\n");

[etc]

>  				if (status & RX_U_CNTRL_FRAME)
> -					printk("rx u control frame\n");
> +					pr_cont("rx u control frame\n");

and finally a pr_cont("\n");

It'd also be good to add 

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

before any #include


