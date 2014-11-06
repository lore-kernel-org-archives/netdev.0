From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 16:25:16 -0500 (EST)
Message-ID: <20141106.162516.1083429539800319166.davem@davemloft.net>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbaKFVZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:25:20 -0500
In-Reply-To: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Nov 2014 16:55:20 -0800

> @@ -4430,8 +4432,19 @@ void napi_complete(struct napi_struct *n)
>  	if (unlikely(test_bit(NAPI_STATE_NPSVC, &n->state)))
>  		return;
>  
> -	napi_gro_flush(n, false);
> +	if (n->gro_list) {
> +		unsigned long timeout = 0;
> +
> +		if (n->napi_rx_count)
> +			timeout = n->dev->gro_flush_timeout;

Under what circumstances would we see n->gro_list non-NULL yet
n->napi_rx_count == 0?

I'm not so sure it can happen.

Said another way, it looks to me like you could implement this
using less state.
