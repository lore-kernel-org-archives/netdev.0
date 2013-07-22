From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ip6mr: change the prototype of ip6_mr_forward().
Date: Mon, 22 Jul 2013 22:47:54 +0200
Message-ID: <51ED9A7A.1010008@6wind.com>
References: <1374364831-13190-1-git-send-email-ramirose@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:55320 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933340Ab3GVUr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 16:47:58 -0400
Received: by mail-we0-f179.google.com with SMTP id t57so1704411wes.24
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 13:47:57 -0700 (PDT)
In-Reply-To: <1374364831-13190-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/07/2013 02:00, Rami Rosen a =C3=A9crit :
> This patch changes the prototpye of the ip6_mr_forward() method to re=
turn void
> instead of int.
>
> The ip6_mr_forward() method always returns 0; moreover, the return va=
lue of this
> method is not checked anywhere.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
>   net/ipv6/ip6mr.c | 11 +++++------
>   1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 583e8d4..6d78615 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -110,8 +110,8 @@ static struct kmem_cache *mrt_cachep __read_mostl=
y;
>   static struct mr6_table *ip6mr_new_table(struct net *net, u32 id);
>   static void ip6mr_free_table(struct mr6_table *mrt);
>
> -static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
> -			  struct sk_buff *skb, struct mfc6_cache *cache);
> +static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
> +			   struct sk_buff *skb, struct mfc6_cache *cache);
>   static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff=
 *pkt,
>   			      mifi_t mifi, int assert);
>   static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buf=
f *skb,
> @@ -2069,8 +2069,8 @@ static int ip6mr_find_vif(struct mr6_table *mrt=
, struct net_device *dev)
>   	return ct;
>   }
>
> -static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
> -			  struct sk_buff *skb, struct mfc6_cache *cache)
> +static void ip6_mr_forward(struct net *net, struct mr6_table *mrt,
> +			   struct sk_buff *skb, struct mfc6_cache *cache)
>   {
>   	int psend =3D -1;
>   	int vif, ct;
> @@ -2151,12 +2151,11 @@ forward:
>   last_forward:
>   	if (psend !=3D -1) {
>   		ip6mr_forward2(net, mrt, skb, cache, psend);
> -		return 0;
> +		return;
>   	}
>
>   dont_forward:
>   	kfree_skb(skb);
> -	return 0;
>   }
