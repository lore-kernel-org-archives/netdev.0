From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] netpoll: netpoll_poll cleanup
Date: Mon, 19 Nov 2007 19:21:09 -0800 (PST)
Message-ID: <20071119.192109.13792248.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.516371353@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753304AbXKTDVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:21:10 -0500
In-Reply-To: <20071103184338.516371353@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:16 -0700

> Restructure code slightly to improve readability:
>   * dereference device once
>   * change obvious while() loop
>   * let poll_napi() handle null list itself
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.25, but I made some coding style fixups, one of
which is a huge pet peeve of mine.

When declaring local variables for a function I always list the
longest lines down gradually to the shortest lines. It is nicer to the
eye and naturally it means that all the complicated structure
assignments and dereferences sit at the top and the simpler iterators
and counters like 'i' end up at the bottom making local variable lists
that much easier to read and search when learning how a function works.

You explicitly changed this one I had set up:

>  {
> -	struct netpoll_info *npinfo = np->dev->npinfo;
> -	struct napi_struct *napi;
>  	int budget = 16;
> +	struct napi_struct *napi;

And I thus reverted it back to the correct order:

	struct napi_struct *napi;
	int budget = 16;

I also got rid of the mid-parens spaces in:

> +		while ( (skb = skb_dequeue(&npi->arp_tx)) )

Thanks.
