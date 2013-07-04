From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] ipmr: change the prototype of ip_mr_forward().
Date: Thu, 04 Jul 2013 21:49:56 +0200
Message-ID: <51D5D1E4.6070909@redhat.com>
References: <1372976155-2490-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756990Ab3GDTuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jul 2013 15:50:18 -0400
In-Reply-To: <1372976155-2490-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2013 12:15 AM, Rami Rosen wrote:
> This patch changes the prototpye of the ip_mr_forward() method to return void
> instead of int.
>
> The ip_mr_forward() method always returns 0; moreover, the retun value of this
> method is not checked anywhere.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

net-next is currently closed. Please resend this when it opens again (announced
on netdev).

> ---
>   net/ipv4/ipmr.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 132a096..83030bf 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -127,7 +127,7 @@ static struct kmem_cache *mrt_cachep __read_mostly;
>   static struct mr_table *ipmr_new_table(struct net *net, u32 id);
>   static void ipmr_free_table(struct mr_table *mrt);
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>   			 struct sk_buff *skb, struct mfc_cache *cache,
>   			 int local);

If you change this here, please also take care of the remaining indent,
which is always aligned at the same column of the opening '(', e.g.:

static void bla(int foo, ...,
		int bar, ...);

Meaning yours needs to be one more space to the right.

>   static int ipmr_cache_report(struct mr_table *mrt,
> @@ -1795,7 +1795,7 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
>
>   /* "local" means that we should preserve one skb (for local delivery) */
>
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>   			 struct sk_buff *skb, struct mfc_cache *cache,
>   			 int local)
>   {
> @@ -1903,14 +1903,13 @@ last_forward:
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
>   }
>
>   static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
>
