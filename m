From: David Miller <davem@davemloft.net>
Subject: Re: More prefetch fall-out
Date: Sun, 22 May 2011 18:15:03 -0400 (EDT)
Message-ID: <20110522.181503.1446789103624635529.davem@davemloft.net>
References: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab1EVWPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 18:15:12 -0400
In-Reply-To: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 22 May 2011 10:49:11 -0700

> However, one of the breakages is <linux/skbuff.h> that does its own
> list-walking functions ("skb_queue_walk*"), and they do prefetching.
> So now I have the option to either just add <linux/prefetch.h> to that
> file, or remove the prefetches. And you're the one that said that the
> prefetches in the networking code were annoying.
> 
> So should the skb queues use prefetching? I have a hard time judging.
> Are those lists usually long? Is the loop usually large enough that
> there is any point to prefetching the next entry?

Please just remove the prefetches.

Those are modelled after list.h as I intend to eventually convert
SKB list handling to "struct list_head" but we're not there yet.

Therefore if we kill prefetches from list.h we should kill it from
these things in skbuff.h too.

Thanks!
