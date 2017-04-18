From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next RFC] net: sched: mirred: move xmit to tasklet
Date: Tue, 18 Apr 2017 13:15:48 -0400 (EDT)
Message-ID: <20170418.131548.824211762596103433.davem@davemloft.net>
References: <20170418130331.14268-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757238AbdDRRPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:15:50 -0400
In-Reply-To: <20170418130331.14268-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 18 Apr 2017 15:03:31 +0200

> mirred is prone to deadlocks as it invokes dev_queue_xmit while
> holding one or more qdisc locks.
> 
> Avoid lock recursions by moving tx context to a tasklet.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  This a stab at removing the lock recursions discussed during netconf.
> 
>  Taking the cost of the tasklet appears to be the only solution;
>  i tried to use a percpu 'history' instead but its not clear to
>  me that this avoids all corner cases.
> 
>  While this patch doesn't avoid loops we don't hang the kernel
>  anymore and removing the 'looping' filter makes things calm
>  down again (there are also other ways to create such loops anyway,
>  including use of a cable... )

The thing is, those qdisc's are per-device.

So we could return the locking cpu and back out of deadlocks just like
we do for the netdev tx lock.

Given that, maybe the remaining part of the equation could possibly be
handled by a ttl.
