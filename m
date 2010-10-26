From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 12:05:39 -0700
Message-ID: <m1sjzs3hbw.fsf@fess.ebiederm.org>
References: <20101026.103428.179941457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel.lezcano@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44928 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760148Ab0JZTFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:05:46 -0400
In-Reply-To: <20101026.103428.179941457.davem@davemloft.net> (David Miller's
	message of "Tue, 26 Oct 2010 10:34:28 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Flush the routing cache only of entries that match the
> network namespace in which the purge event occurred.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> Could I get some testing and performance analysis feedback
> on this change?  I don't want it to just die :-)
>
> THanks!
>
> diff --git a/include/net/route.h b/include/net/route.h
> index 7e5e73b..8d24761 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -106,7 +106,7 @@ extern int		ip_rt_init(void);
>  extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
>  				       __be32 src, struct net_device *dev);
>  extern void		rt_cache_flush(struct net *net, int how);
> -extern void		rt_cache_flush_batch(void);
> +extern void		rt_cache_flush_batch(struct net *net);
>  extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
>  extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
>  extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 36e27c2..828d471 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  		rt_cache_flush(dev_net(dev), 0);
>  		break;
>  	case NETDEV_UNREGISTER_BATCH:
> -		rt_cache_flush_batch();
> +		rt_cache_flush_batch(dev_net(dev));

It still has this incorrect conversion in it.

Eric
