From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH net-next 2/2] ip_tunnel: Protect tunnel functions with
 CONFIG_INET guard.
Date: Fri, 21 Jun 2013 20:46:51 -0700
Message-ID: <51C51E2B.7050704@infradead.org>
References: <1371856631-47807-1-git-send-email-jesse@nicira.com> <1371856631-47807-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51432 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423471Ab3FVDrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 23:47:12 -0400
In-Reply-To: <1371856631-47807-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/13 16:17, Jesse Gross wrote:
> Tunnel constants can be used in generic code but in these cases
> the inline functions in ip_tunnels.h cause compilation problems
> if CONFIG_INET is not set.
> 
> CC: Pravin Shelar <pshelar@nicira.com>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.


> ---
>  include/net/ip_tunnels.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
> index 10bbb42..b0d9824 100644
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -93,6 +93,8 @@ struct ip_tunnel_net {
>  	struct net_device *fb_tunnel_dev;
>  };
>  
> +#ifdef CONFIG_INET
> +
>  int ip_tunnel_init(struct net_device *dev);
>  void ip_tunnel_uninit(struct net_device *dev);
>  void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
> @@ -180,4 +182,7 @@ static inline void iptunnel_xmit_stats(int err,
>  		err_stats->tx_dropped++;
>  	}
>  }
> +
> +#endif /* CONFIG_INET */
> +
>  #endif /* __NET_IP_TUNNELS_H */
> 


-- 
~Randy
