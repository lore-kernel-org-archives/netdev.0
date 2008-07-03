From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/39]: pkt_sched: Add qdisc_tx_is_noop() helper and use
 in IPV6.
Date: Thu, 3 Jul 2008 08:58:03 -0700
Message-ID: <20080703085803.3a81d67c@extreme>
References: <20080703.000349.266937189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080703.000349.266937189.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 03 Jul 2008 00:03:49 -0700 (PDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> 
> This indicates if the NOOP scheduler is what is active
> for TX on a given device.
> 
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  include/net/sch_generic.h |    8 ++++++++
>  net/ipv6/addrconf.c       |    5 ++---
>  2 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 9f5e644..bfb05a7 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -212,6 +212,14 @@ static inline bool qdisc_tx_changing(struct net_device *dev)
>  	return (txq->qdisc != txq->qdisc_sleeping);
>  }
>  
> +/* Is the device using the noop qdisc?  */
> +static inline bool qdisc_tx_is_noop(struct net_device *dev)
> +{
> +	struct netdev_queue *txq = &dev->tx_queue;
> +
> +	return (txq->qdisc == &noop_qdisc);
> +}
static inline bool qdisc_tx_is_noop(const struct net_device *dev)?

>  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
>  				       struct sk_buff_head *list)
>  {
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index e6acb89..6dd8c63 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -224,10 +224,9 @@ const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_IN
>  const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
>  
>  /* Check if a valid qdisc is available */
> -static inline int addrconf_qdisc_ok(struct net_device *dev)
> +static inline bool addrconf_qdisc_ok(struct net_device *dev)
>  {
> -	struct netdev_queue *txq = &dev->tx_queue;
> -	return (txq->qdisc != &noop_qdisc);
> +	return !qdisc_tx_is_noop(dev);
>  }

Ditto const
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
