From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: remove twchain
Date: Thu, 03 Oct 2013 17:51:07 -0400 (EDT)
Message-ID: <20131003.175107.1919190333940976775.davem@davemloft.net>
References: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414Ab3JCVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:51:09 -0400
In-Reply-To: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Oct 2013 00:22:02 -0700

> Current inet_ehash_bucket contains two chains, one for ESTABLISH (and
> friend states) sockets, another for TIME_WAIT sockets only.
> 
> As the hash table is sized to get at most one socket per bucket, it
> makes little sense to have separate twchain, as it makes the lookup
> slightly more complicated, and doubles hash table memory usage.

The idea was that long standing time-wait sockets should be forced to
provably never appear in same hash chains and thus cause interference
with lookups on established sockets.

On the other hand, moving sockets between these two tables has a
non-trivial cost, and synchronization complexity.

So perhaps your change gives the right tradeoff.

Eric this patch needs to be respun against current net-next
in order for it to apply cleanly, please do that and I'll add
it.

Thanks!
