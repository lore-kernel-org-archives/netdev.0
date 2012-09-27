From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/3] net: add gro_cells infrastructure
Date: Fri, 28 Sep 2012 01:27:37 +0200
Message-ID: <1348788457.10741.39.camel@deadeye.wl.decadent.org.uk>
References: <1348750077.5093.1224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62584 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754952Ab2I0X1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:27:49 -0400
In-Reply-To: <1348750077.5093.1224.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 14:47 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> This adds a new include file (include/net/gro_cells.h), to bring GRO
> (Generic Receive Offload) capability to tunnels, in a modular way.
> 
> Because tunnels receive path is lockless, and GRO adds a serialization
> using a napi_struct, I chose to add an array of up to 8 cells,
> so that multi queue devices wont be slowed down because of GRO layer.
> 
> skb_get_rx_queue() is used as selector.
> 
> In the future, we might add optional fanout capabilities, using rxhash
> for example.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/gro_cells.h |  103 ++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c          |    2 
>  2 files changed, 105 insertions(+)
> 
> diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
> new file mode 100644
> index 0000000..ba93b1b
> --- /dev/null
> +++ b/include/net/gro_cells.h
[...]
> +static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *dev)
> +{
> +	int i;
> +
> +	gcells->gro_cells_mask = roundup_pow_of_two(min_t(unsigned int, 8, nr_cpu_ids)) - 1;
[...]

Perhaps this ought to use netif_get_num_default_rss_queues() instead of
open-coding something similar.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
