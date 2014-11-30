From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next v2] bridge: make proxy arp configurable
Date: Sun, 30 Nov 2014 19:20:46 +0100
Message-ID: <20141130182046.GA16296@kria>
References: <20141130092001.7168dc72@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Kyeyoon Park <kyeyoonp@codeaurora.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:42578 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbaK3SUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2014 13:20:53 -0500
Content-Disposition: inline
In-Reply-To: <20141130092001.7168dc72@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

2014-11-30, 09:20:01 -0800, Stephen Hemminger wrote:
> 
> This solves kernel build without INET enabled, and allows user
> to control enabling this feature.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
>  net/bridge/Kconfig       |   15 +++++++++++++++
>  net/bridge/br_input.c    |    4 ++++
>  net/bridge/br_sysfs_if.c |    4 ++++
>  3 files changed, 23 insertions(+)
> 
> --- a/net/bridge/Kconfig	2014-11-25 09:42:34.687891662 -0800
> +++ b/net/bridge/Kconfig	2014-11-25 09:42:34.683891643 -0800
> @@ -60,3 +60,18 @@ config BRIDGE_VLAN_FILTERING
>  	  Say N to exclude this support and reduce the binary size.
>  
>  	  If unsure, say Y.
> +
> +config BRIDGE_ARP_PROXY

Shouldn't this be BRIDGE_PROXY_ARP to match all the

  #ifdef CONFIG_BRIDGE_PROXY_ARP

below?


> --- a/net/bridge/br_input.c	2014-11-25 09:42:34.687891662 -0800
> +++ b/net/bridge/br_input.c	2014-11-25 09:42:34.683891643 -0800
> @@ -59,6 +59,7 @@ static int br_pass_frame_up(struct sk_bu
>  		       netif_receive_skb);
>  }
>  
> +#ifdef CONFIG_BRIDGE_PROXY_ARP
>  static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
>  			    u16 vid)
>  {
> @@ -112,6 +113,7 @@ static void br_do_proxy_arp(struct sk_bu
>  		neigh_release(n);
>  	}
>  }
> +#endif


-- 
Sabrina
