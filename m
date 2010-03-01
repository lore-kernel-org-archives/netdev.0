From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6] bridge: Fix build error when IGMP_SNOOPING
 is not enabled
Date: Mon, 01 Mar 2010 12:54:17 -0800
Message-ID: <4B8C2979.3080902@oracle.com>
References: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47910 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab0CAU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 15:57:22 -0500
In-Reply-To: <1267473184.31728.7.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/10 11:53, Sridhar Samudrala wrote:
> Fix the following build error when IGMP_SNOOPING is not enabled.
> In file included from net/bridge/br.c:24:
> net/bridge/br_private.h: In function 'br_multicast_is_router':
> net/bridge/br_private.h:361: error: 'struct net_bridge' has no member named 'multicast_router'
> net/bridge/br_private.h:362: error: 'struct net_bridge' has no member named 'multicast_router'
> net/bridge/br_private.h:363: error: 'struct net_bridge' has no member named 'multicast_router_timer'
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 9191198..1cf2cef 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -302,6 +302,13 @@ extern int br_multicast_set_port_router(struct net_bridge_port *p,
>  					unsigned long val);
>  extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
>  extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
> +
> +static inline bool br_multicast_is_router(struct net_bridge *br)
> +{
> +	return br->multicast_router == 2 ||
> +	       (br->multicast_router == 1 &&
> +		timer_pending(&br->multicast_router_timer));
> +}
>  #else
>  static inline int br_multicast_rcv(struct net_bridge *br,
>  				   struct net_bridge_port *port,
> @@ -354,14 +361,11 @@ static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
>  					struct sk_buff *skb2)
>  {
>  }
> -#endif
> -
>  static inline bool br_multicast_is_router(struct net_bridge *br)
>  {
> -	return br->multicast_router == 2 ||
> -	       (br->multicast_router == 1 &&
> -		timer_pending(&br->multicast_router_timer));
> +	return 0;
>  }
> +#endif
>  
>  /* br_netfilter.c */
>  #ifdef CONFIG_BRIDGE_NETFILTER
> 
> 
> --

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>


Thanks.
-- 
~Randy
