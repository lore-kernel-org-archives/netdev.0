From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] tcp/dccp: remove twchain
Date: Thu, 3 Oct 2013 21:04:45 +0100
Message-ID: <1380830685.3419.13.camel@bwh-desktop.uk.level5networks.com>
References: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43019 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385Ab3JCUEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 16:04:49 -0400
In-Reply-To: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 00:22 -0700, Eric Dumazet wrote:
[...]
> @@ -146,26 +150,21 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
>  	spin_lock(lock);
>  
>  	/*
> -	 * Step 2: Hash TW into TIMEWAIT chain.
> -	 * Should be done before removing sk from established chain
> -	 * because readers are lockless and search established first.
> +	 * Step 2: Hash TW into tcp ehash chain.
> +	 * Notes :
> +	 * - tw_refcnt is set to 3 because :
> +	 * - We have one reference from bhash chain.
> +	 * - We have one reference from ehash chain.
> +	 * We can use atomic_set() because prior spin_lock()/spin_unlock()
> +	 * committed into memory all tw fields.
>  	*/
> -	inet_twsk_add_node_rcu(tw, &ehead->twchain);
> +	atomic_set(&tw->tw_refcnt, 1 + 1 + 1);
> +	inet_twsk_add_node_rcu(tw, &ehead->chain);
[...]

'will commit' rather than 'committed'?

But isn't this also a separate optimisation?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
