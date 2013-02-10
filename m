From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: don't accept multicast traffic with scop 0
Date: Sun, 10 Feb 2013 23:56:02 +0900
Message-ID: <5117B502.3020001@linux-ipv6.org>
References: <20130210124851.GB18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, erik.hugne@ericsson.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34722 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755665Ab3BJO4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 09:56:03 -0500
In-Reply-To: <20130210124851.GB18219@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_input.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 4ac5bf3..34ddebd 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -126,6 +126,16 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>  	if (ipv6_addr_is_multicast(&hdr->saddr))
>  		goto err;
>  
> +	/*
> +	 * RFC4291 2.7
> +	 * Nodes must not originate a packet to a multicast address whose scop
> +	 * field contains the reserved value 0; if such a packet is received, it
> +	 * must be silently dropped.
> +	 */
> +	if (ipv6_addr_is_multicast(&hdr->daddr) &&
> +	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 0)
> +		goto err;
> +
>  	skb->transport_header = skb->network_header + sizeof(*hdr);
>  	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
>  
> 

Would you place this before saddr check, just after loopback check, please?
Otherwise,

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
