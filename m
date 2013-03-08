From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v3 3/4] ipv6: stop multicast forwarding to process
 interface scoped addresses
Date: Fri, 08 Mar 2013 11:19:11 +0900
Message-ID: <51394A9F.8000003@linux-ipv6.org>
References: <20130307210537.GA23729@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40132 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751029Ab3CHCTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 21:19:12 -0500
In-Reply-To: <20130307210537.GA23729@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> v2:
> a) used struct ipv6_addr_props
> 
> v3:
> a) reverted changes for ipv6_addr_props
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index b1876e5..b73bcc2 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -281,7 +281,7 @@ int ip6_mc_input(struct sk_buff *skb)
>  	 *      IPv6 multicast router mode is now supported ;)
>  	 */
>  	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
> -	    !(ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
> +	    !__ipv6_addr_needs_scope_id((ipv6_addr_type(&hdr->daddr))) &&
>  	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
>  		/*
>  		 * Okay, we try to forward - split and duplicate
> 

Well, I think __ipv6_addr_needs_scope_id() should be used just for
filling "sin6_scope_id", not for forwarding decision.

Since we always have multicast address, so 
            !(ipv6_addr_type(&hdr->daddr) & (IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL))
is just fine for disallow "forwarding" multicast for interface-local addresses.

--yoshfuji
