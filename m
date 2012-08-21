From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix possible socket refcount problem
Date: Tue, 21 Aug 2012 14:43:27 -0700 (PDT)
Message-ID: <20120821.144327.1729675246155381935.davem@davemloft.net>
References: <20120818021918.GA6499@localhost>
	<1345380682.5158.201.camel@edumazet-glaptop>
	<1345458166.5158.316.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758482Ab2HUVna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 17:43:30 -0400
In-Reply-To: <1345458166.5158.316.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Aug 2012 12:22:46 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 6f458dfb40 (tcp: improve latencies of timer triggered events)
> added bug leading to following trace :
 ...
> The bug comes from the fact that timer set in sk_reset_timer() can run
> before we actually do the sock_hold(). socket refcount reaches zero and
> we free the socket too soon.
> 
> timer handler is not allowed to reduce socket refcnt if socket is owned
> by the user, or we need to change sk_reset_timer() implementation.
> 
> We should take a reference on the socket in case TCP_DELACK_TIMER_DEFERRED
> or TCP_DELACK_TIMER_DEFERRED bit are set in tsq_flags
> 
> Also fix a typo in tcp_delack_timer(), where TCP_WRITE_TIMER_DEFERRED
> was used instead of TCP_DELACK_TIMER_DEFERRED.
> 
> For consistency, use same socket refcount change for TCP_MTU_REDUCED_DEFERRED,
> even if not fired from a timer.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Tested-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
