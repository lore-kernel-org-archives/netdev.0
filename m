From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Sat, 13 Nov 2010 09:35:45 -0800
Message-ID: <20101113093545.6fe9c077@nehalam>
References: <1289636128.2743.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60426 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239Ab0KMRj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 12:39:28 -0500
In-Reply-To: <1289636128.2743.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Nov 2010 09:15:28 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 578debb..ffbd177 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -996,7 +996,10 @@ struct net_device {
>  #endif
>  
>  	rx_handler_func_t	*rx_handler;
> -	void			*rx_handler_data;
> +	union {
> +		void				*rx_handler_data;
> +		struct net_bridge_port __rcu	*br_port_rcu;
> +	};
>  
>  	struct netdev_queue __rcu *ingress_queue;

I don't like making the generic hook typed again.
We don't do this for other callbacks, timers, workqueues, ...
Why is it necessary for RCU notation.

-- 
