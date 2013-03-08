From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next v4 3/4] ipv6: stop multicast forwarding to process
 interface scoped addresses
Date: Sat, 09 Mar 2013 01:30:20 +0900
Message-ID: <513A121C.7010702@linux-ipv6.org>
References: <20130308120723.GA5120@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60586 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933136Ab3CHQaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:30:21 -0500
In-Reply-To: <20130308120723.GA5120@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> v2:
> a) used struct ipv6_addr_props
> 
> v3:
> a) reverted changes for ipv6_addr_props
> 
> v4:
> a) do not use __ipv6_addr_needs_scope_id
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/ip6_input.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index b1876e5..e33fe0a 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -281,7 +281,8 @@ int ip6_mc_input(struct sk_buff *skb)
>  	 *      IPv6 multicast router mode is now supported ;)
>  	 */
>  	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
> -	    !(ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
> +	    !(ipv6_addr_type(&hdr->daddr) &
> +	      (IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL)) &&
>  	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
>  		/*
>  		 * Okay, we try to forward - split and duplicate
> 
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

And I think this should go to -stable as well,.

--yoshfuji
