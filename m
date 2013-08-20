From: David Miller <davem@davemloft.net>
Subject: Re: About tcp: set timestamps for restored skb-s
Date: Tue, 20 Aug 2013 13:08:06 -0700 (PDT)
Message-ID: <20130820.130806.2180396135396793576.davem@davemloft.net>
References: <1376786376.21329.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3HTUIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:08:07 -0400
In-Reply-To: <1376786376.21329.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Aug 2013 17:39:36 -0700

> Because of gmail.com problems, I missed lot of netdev traffic
> 
> Related to :
> 
> http://patchwork.ozlabs.org/patch/267678/
> 
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 5423223..b2f6c74 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1121,6 +1121,13 @@  new_segment:
>  					goto wait_for_memory;
>  
>  				/*
> +				 * All packets are restored as if they have
> +				 * already been sent.
> +				 */
> +				if (tp->repair)
> +					TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +
> 
> The test could be removed.
> 
> Setting @when for regular sends seems harmless

I applied this before reading this, sorry.

It can be cleaned up in net-next eventually.
