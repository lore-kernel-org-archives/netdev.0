From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip_fragment: fix subtracting PPPOE_SES_HLEN from mtu
 twice
Date: Mon, 02 Aug 2010 17:50:57 +0200
Message-ID: <4C56E961.9070107@trash.net>
References: <1280618708-9241-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Bart De Schuymer <bdschuym@pandora.be>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62574 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969Ab0HBPu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 11:50:57 -0400
In-Reply-To: <1280618708-9241-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.08.2010 01:25, Changli Gao wrote:
> 6c79bf0f2440fd250c8fce8d9b82fcf03d4e8350 subtracts PPPOE_SES_HLEN from mtu at
> the front of ip_fragment(). So the later subtraction should be removed. The
> MTU of 802.1q is also 1500, so MTU should not be changed.

Bart, please review, thanks.

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/ipv4/ip_output.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 6652bd9..04b6989 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -446,7 +446,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
>  	int ptr;
>  	struct net_device *dev;
>  	struct sk_buff *skb2;
> -	unsigned int mtu, hlen, left, len, ll_rs, pad;
> +	unsigned int mtu, hlen, left, len, ll_rs;
>  	int offset;
>  	__be16 not_last_frag;
>  	struct rtable *rt = skb_rtable(skb);
> @@ -585,9 +585,7 @@ slow_path:
>  	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
>  	 * we need to make room for the encapsulating header
>  	 */
> -	pad = nf_bridge_pad(skb);
> -	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, pad);
> -	mtu -= pad;
> +	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
>  
>  	/*
>  	 *	Fragment the datagram.
> 

