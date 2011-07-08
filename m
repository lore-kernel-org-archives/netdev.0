From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net: Omit check for multicast bit in
 netdev_for_each_mc_addr
Date: Fri, 08 Jul 2011 01:35:09 -0700
Message-ID: <1310114109.2755.18.camel@Joe-Laptop>
References: <1310112386-13716-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jaroslav Kysela <perex@perex.cz>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3670 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389Ab1GHIfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 04:35:11 -0400
In-Reply-To: <1310112386-13716-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-08 at 10:06 +0200, Tobias Klauser wrote:
> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.

Thanks Tobias.

The commit message is a bit redundant, but this looks
good to me.

[]
> diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
[]
> @@ -2103,20 +2103,18 @@ static void hp100_set_multicast_list(struct net_device *dev)
>  #endif
>  			netdev_for_each_mc_addr(ha, dev) {
>  				addrs = ha->addr;
> -				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
>  #ifdef HP100_DEBUG
> -					printk("hp100: %s: multicast = %pM, ",
> -						     dev->name, addrs);
> +				printk("hp100: %s: multicast = %pM, ",
> +					     dev->name, addrs);
>  #endif
> -					for (i = idx = 0; i < 6; i++) {
> -						idx ^= *addrs++ & 0x3f;
> -						printk(":%02x:", idx);
> -					}
> +				for (i = idx = 0; i < 6; i++) {
> +					idx ^= *addrs++ & 0x3f;
> +					printk(":%02x:", idx);
> +				}

It looks as if printing the per-byte hash
should also be guarded by HP100_DEBUG.

It's been this way since at least 2.4.1 though.

Does anyone still use this adapter?


