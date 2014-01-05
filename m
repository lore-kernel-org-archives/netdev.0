From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 00:05:05 +0100
Message-ID: <20140105230505.GA29910@order.stressinduktion.org>
References: <1388767411-17818-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40846 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaAEXFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 18:05:07 -0500
Content-Disposition: inline
In-Reply-To: <1388767411-17818-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail wrote:
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 5d42009..65c8619 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>  
>  	saddr = &ipv6_hdr(skb)->daddr;
>  
> -	if (!ipv6_unicast_destination(skb))
> +	if (!ipv6_unicast_destination(skb) &&
> +	    !(net->ipv6.anycast_src_echo_reply &&
> +	      ipv6_chk_acast_addr(net, NULL, saddr)))
>  		saddr = NULL;

I am not sure why you left out the device at ipv6_chk_acast_addr?

IMHO this logic is a bit more complex, we can pass NULL for ipv6 addresses of
scope global but need to check the interface for scope link.

It is already possible via setsockopt JOIN_ANYCAST that an ll address is
anycast on another interface which may not be checked here.

Greetings,

  Hannes
