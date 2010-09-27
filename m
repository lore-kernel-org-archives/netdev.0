From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next 2/4] ip_gre: percpu stats accounting
Date: Mon, 27 Sep 2010 14:29:00 +0100
Message-ID: <1285594140.2263.0.camel@achroite.uk.solarflarecom.com>
References: <1285583707.23938.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26731 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab0I0N3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:29:10 -0400
In-Reply-To: <1285583707.23938.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-09-27 at 12:35 +0200, Eric Dumazet wrote:
> Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.
> 
> Other seldom used fields are kept in netdev->stats structure, possibly
> unsafe.
> 
> This is a preliminary work to support lockless transmit path, and
> correct RX stats, that are already unsafe.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/ip_gre.c |  138 +++++++++++++++++++++++++++++++-------------
>  1 file changed, 99 insertions(+), 39 deletions(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 5d6ddcb..de39b22 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
[...]
> @@ -377,7 +405,7 @@ static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
>  	if (parms->name[0])
>  		strlcpy(name, parms->name, IFNAMSIZ);
>  	else
> -		sprintf(name, "gre%%d");
> +		strcpy(name, "gre%d");
>  
>  	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
>  	if (!dev)
[...]

This is a valid fix, but doesn't belong in this patch!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

