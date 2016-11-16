From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netpoll: more efficient locking
Date: Wed, 16 Nov 2016 18:32:13 -0500 (EST)
Message-ID: <20161116.183213.1491793896240161705.davem@davemloft.net>
References: <1479336890.8455.225.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753892AbcKQB7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 20:59:37 -0500
In-Reply-To: <1479336890.8455.225.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 14:54:50 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Callers of netpoll_poll_lock() own NAPI_STATE_SCHED
> 
> Callers of netpoll_poll_unlock() have BH blocked between
> the NAPI_STATE_SCHED being cleared and poll_lock is released.
> 
> We can avoid the spinlock which has no contention, and use cmpxchg()
> on poll_owner which we need to set anyway.
> 
> This removes a possible lockdep violation after the cited commit,
> since sk_busy_loop() re-enables BH before calling busy_poll_stop()
> 
> Fixes: 217f69743681 ("net: busy-poll: allow preemption in sk_busy_loop()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
