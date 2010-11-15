From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: use the macros defined for the members of flowi
Date: Mon, 15 Nov 2010 16:33:04 -0500
Message-ID: <4CE1A710.9040603@hp.com>
References: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:17658 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab0KOVdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:33:07 -0500
In-Reply-To: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2010 11:43 PM, Changli Gao wrote:
> Use the macros defined for the members of flowi to clean the code up.
> 
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 865fd76..36cd0b7 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -412,13 +412,8 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
>  	if (dnat_took_place(skb)) {
>  		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
>  			struct flowi fl = {
> -				.nl_u = {
> -					.ip4_u = {
> -						 .daddr = iph->daddr,
> -						 .saddr = 0,
> -						 .tos = RT_TOS(iph->tos) },
> -				},
> -				.proto = 0,
> +				.fl4_dst = iph->daddr,
> +				.fl4_tos = RT_TOS(iph->tos),
>  			};

Are these actually equivalent?  You dropped two assignments to zero.
I always thought things on the stack weren't.

Thanks,

-Brian
