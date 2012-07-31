From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] ipv4: Fix dangling netdev refs
Date: Mon, 30 Jul 2012 18:23:25 -0700 (PDT)
Message-ID: <20120730.182325.572061220480380949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab2GaBX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 21:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, this should give you an idea of what I was working on.

It really assumes the universe in place before your change last
night.  It is very likely we'll have to revert it and look for
another solution to the problem you were trying to solve.  And
actually I don't understand the actual bug very well.

I can only assume that the core issue was that, unlike back when
we had the routing cache, the fib_info nexthops are not persistent
memory like the routing cache hash table was?

Otherwise I can see absolutely no change in reference counting and
dst destruction logic between the routing cache, and how I modified
fib_info nexthop cached routes to behave.

Anyways, the first patch caches routes in the nexthop exception
entries.

And the second patch has a global list for uncached routes so we
can purge netdevice references properly when such devices are
unregistered.

Signed-off-by: David S. Miller <davem@davemloft.net>
