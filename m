From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] tcp_memcontrol: fix reversed if condition
Date: Thu, 15 Dec 2011 12:01:08 -0500 (EST)
Message-ID: <20111215.120108.663752764643957547.davem@davemloft.net>
References: <20111215110510.GA2674@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: glommer@parallels.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759192Ab1LOREJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 12:04:09 -0500
In-Reply-To: <20111215110510.GA2674@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 15 Dec 2011 14:05:10 +0300

> We should only dereference the pointer if it's valid, not the other way
> round.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

It's nice to see how thoroughly this code has been tested, sigh...

Applied, thanks a lot Dan.

> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 171d7b6..7fed04f 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -44,7 +44,7 @@ static inline struct tcp_memcontrol *tcp_from_cgproto(struct cg_proto *cg_proto)
>  
>  static void memcg_tcp_enter_memory_pressure(struct sock *sk)
>  {
> -	if (!sk->sk_cgrp->memory_pressure)
> +	if (sk->sk_cgrp->memory_pressure)
>  		*sk->sk_cgrp->memory_pressure = 1;
>  }
>  EXPORT_SYMBOL(memcg_tcp_enter_memory_pressure);
