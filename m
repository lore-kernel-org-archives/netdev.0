From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: more robust memory allocation
Date: Sat, 14 Dec 2013 01:19:42 -0500 (EST)
Message-ID: <20131214.011942.1693344941253042499.davem@davemloft.net>
References: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab3LNGTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:19:44 -0500
In-Reply-To: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Dec 2013 16:35:12 -0800

> @@ -578,15 +579,32 @@ static void fq_rehash(struct fq_sched_data *q,
>  	q->stat_gc_flows += fcnt;
>  }
>  
> -static int fq_resize(struct fq_sched_data *q, u32 log)
> +static void fq_free(void *addr)
>  {
> +	if (addr && is_vmalloc_addr(addr))
> +		vfree(addr);
> +	else
> +		kfree(addr);
> +}
 ...
> +	array = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN,
> +			     node);
> +	if (!array)
> +		array = vmalloc_node(sz, node);

Eric, please make a "fq_alloc()" which does this:

	x = kmalloc;
	if (!x)
		x = vmalloc;

dance, in order to complement fq_free().

thanks.
