From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] ipv6: don't accept multicast traffic with scop 0
Date: Mon, 11 Feb 2013 03:09:23 +0900
Message-ID: <5117E253.5040704@linux-ipv6.org>
References: <20130210153522.GA20897@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39423 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756201Ab3BJSJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 13:09:25 -0500
In-Reply-To: <20130210153522.GA20897@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> v2:
> a) moved before multicast source address check
> b) changed comment to netdev style
> 
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_input.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 4ac5bf3..521d9fd 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -118,6 +118,15 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>  	    ipv6_addr_loopback(&hdr->daddr))
>  		goto err;
>  
> +	/* RFC4291 2.7
> +	 * Nodes must not originate a packet to a multicast address whose scop
> +	 * field contains the reserved value 0; if such a packet is received, it
> +	 * must be silently dropped.
> +	 */
> +	if (ipv6_addr_is_multicast(&hdr->daddr) &&
> +	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 0)
> +		goto err;
> +
>  	/*
>  	 * RFC4291 2.7
>  	 * Multicast addresses must not be used as source addresses in IPv6
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
