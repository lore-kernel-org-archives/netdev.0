From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ipmr: change the prototype of ip_mr_forward().
Date: Thu, 04 Jul 2013 18:49:36 +0200
Message-ID: <51D5A7A0.2020606@6wind.com>
References: <1372962275-29138-1-git-send-email-ramirose@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:61757 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762Ab3GDQtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 12:49:40 -0400
Received: by mail-wg0-f50.google.com with SMTP id k14so1306265wgh.17
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 09:49:38 -0700 (PDT)
In-Reply-To: <1372962275-29138-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/07/2013 20:24, Rami Rosen a =C3=A9crit :
> This patch changes the prototpye of the ip_mr_forward() method to ret=
urn void
> instead of int.
>
> The ip_mr_forward() method always returns 0; moreover, the retun valu=
e
> of this method is not checked anywhere.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> ---
>   net/ipv4/ipmr.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 132a096..eca2742 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -127,7 +127,7 @@ static struct kmem_cache *mrt_cachep __read_mostl=
y;
>   static struct mr_table *ipmr_new_table(struct net *net, u32 id);
>   static void ipmr_free_table(struct mr_table *mrt);
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>   			 struct sk_buff *skb, struct mfc_cache *cache,
>   			 int local);
>   static int ipmr_cache_report(struct mr_table *mrt,
> @@ -1795,7 +1795,7 @@ static int ipmr_find_vif(struct mr_table *mrt, =
struct net_device *dev)
>
>   /* "local" means that we should preserve one skb (for local deliver=
y) */
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>   			 struct sk_buff *skb, struct mfc_cache *cache,
>   			 int local)
>   {
> @@ -1903,14 +1903,14 @@ last_forward:
>   				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
>   		} else {
>   			ipmr_queue_xmit(net, mrt, skb, cache, psend);
> -			return 0;
> +			return;
>   		}
>   	}
>
>   dont_forward:
>   	if (!local)
>   		kfree_skb(skb);
> -	return 0;
> +	return;
This is the end of the function, you can just remove this 'return'.
