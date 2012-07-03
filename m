From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 12/19] neigh: Convert over to dst_neigh_lookup_skb().
Date: Tue, 3 Jul 2012 23:08:29 +0100
Message-ID: <1341353309.2839.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120703.024644.638173463391088464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63941 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756313Ab2GCWIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 18:08:36 -0400
In-Reply-To: <20120703.024644.638173463391088464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-03 at 02:46 -0700, David Miller wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/neighbour.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index a793af9..eb3efdc 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1202,9 +1202,15 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  
>  			rcu_read_lock();
>  			/* On shaper/eql skb->dst->neighbour != neigh :( */

It might be time to delete that comment too.

Ben.

> -			if (dst && (n2 = dst_get_neighbour_noref(dst)) != NULL)
> -				n1 = n2;
> +			n2 = NULL;
> +			if (dst) {
> +				n2 = dst_neigh_lookup_skb(dst, skb);
> +				if (n2)
> +					n1 = n2;
> +			}
>  			n1->output(n1, skb);
> +			if (n2)
> +				neigh_release(n2);
>  			rcu_read_unlock();
>  
>  			write_lock_bh(&neigh->lock);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
