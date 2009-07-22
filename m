From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH V2 net-next-2.6] net: relax dst refcnt in input path
Date: Wed, 22 Jul 2009 14:40:06 +0200
Message-ID: <4A6708A6.1090200@trash.net>
References: <4A66201D.9070103@gmail.com> <4A670469.2050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65477 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbZGVMkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 08:40:08 -0400
In-Reply-To: <4A670469.2050404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index db46b4b..23e974b 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -331,7 +331,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
>  	 */
>  	if (skb_dst(skb) == NULL) {
>  		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
> -					 skb->dev);
> +					 skb->dev, 1);
>  		if (unlikely(err)) {
>  			if (err == -EHOSTUNREACH)
>  				IP_INC_STATS_BH(dev_net(skb->dev),


The packet might get queued by netfilter after this. I think this needs
another skb_dst_force() in __nf_queue().
