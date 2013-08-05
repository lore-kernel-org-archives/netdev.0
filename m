From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: remove potential out of bound access
Date: Mon, 05 Aug 2013 15:27:01 -0700 (PDT)
Message-ID: <20130805.152701.1330956846335649347.davem@davemloft.net>
References: <1375726729.4457.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3HEW1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 18:27:03 -0400
In-Reply-To: <1375726729.4457.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Aug 2013 11:18:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> AddressSanitizer [1] dynamic checker pointed a potential
> out of bound access in leaf_walk_rcu()
> 
> We could allocate one more slot in tnode_new() to leave the prefetch()
> in-place but it looks not worth the pain.
> 
> Bug added in commit 82cfbb008572b ("[IPV4] fib_trie: iterator recode")
> 
> [1] :
> https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I question the validity of the prefetch anyways, even without the
out-of-bounds concerns.

Applied and queued up for -stable, thanks Eric.
