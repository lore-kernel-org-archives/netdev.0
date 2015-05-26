From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix/cleanup inet_ehash_locks_alloc()
Date: Tue, 26 May 2015 19:48:58 -0400 (EDT)
Message-ID: <20150526.194858.341347965444056849.davem@davemloft.net>
References: <1432652134.4060.244.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbEZXtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 19:49:00 -0400
In-Reply-To: <1432652134.4060.244.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2015 07:55:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If tcp ehash table is constrained to a very small number of buckets
> (eg boot parameter thash_entries=128), then we can crash if spinlock
> array has more entries.
> 
> While we are at it, un-inline inet_ehash_locks_alloc() and make
> following changes :
> 
> - Budget 2 cache lines per cpu worth of 'spinlocks'
> - Try to kmalloc() the array to avoid extra TLB pressure.
>   (Most servers at Google allocate 8192 bytes for this hash table)
> - Get rid of various #ifdef
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
