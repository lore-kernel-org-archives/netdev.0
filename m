From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: remove unused list
Date: Wed, 08 Jun 2011 17:05:57 -0700 (PDT)
Message-ID: <20110608.170557.2273990802892743973.davem@davemloft.net>
References: <1307513916.3102.23.camel@edumazet-laptop>
	<1307514470.3102.25.camel@edumazet-laptop>
	<1307576134.3980.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, andi@firstfloor.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1FIAGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:06:07 -0400
In-Reply-To: <1307576134.3980.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jun 2011 01:35:34 +0200

> Andi Kleen and Tim Chen reported huge contention on inetpeer
> unused_peers.lock, on memcached workload on a 40 core machine, with
> disabled route cache.
> 
> It appears we constantly flip peers refcnt between 0 and 1 values, and
> we must insert/remove peers from unused_peers.list, holding a contended
> spinlock.
> 
> Remove this list completely and perform a garbage collection on-the-fly,
> at lookup time, using the expired nodes we met during the tree
> traversal.
> 
> This removes a lot of code, makes locking more standard, and obsoletes
> two sysctls (inet_peer_gc_mintime and inet_peer_gc_maxtime). This also
> removes two pointers in inet_peer structure.
> 
> There is still a false sharing effect because refcnt is in first cache
> line of object [were the links and keys used by lookups are located], we
> might move it at the end of inet_peer structure to let this first cache
> line mostly read by cpus.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Didn't expect you to implement this so fast :-)

Applied, thanks!
