From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: remove spinlock usage in fast path
Date: Mon, 20 May 2013 14:01:18 -0700 (PDT)
Message-ID: <20130520.140118.176987219677786436.davem@davemloft.net>
References: <1369068746.3301.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757092Ab3ETVBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 17:01:18 -0400
In-Reply-To: <1369068746.3301.194.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 May 2013 09:52:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP md5 code uses per cpu variables but protects access to them with
> a shared spinlock, which is a contention point.
> 
> [ tcp_md5sig_pool_lock is locked twice per incoming packet ]
> 
> Makes things much simpler, by allocating crypto structures once, first
> time a socket needs md5 keys, and not deallocating them as they are
> really small.
> 
> Next step would be to allow crypto allocations being done in a NUMA
> aware way.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
