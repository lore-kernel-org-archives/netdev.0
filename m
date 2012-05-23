From: David Miller <davem@davemloft.net>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 13:34:01 -0400 (EDT)
Message-ID: <20120523.133401.915684077769386834.davem@davemloft.net>
References: <1337705135.3361.226.camel@edumazet-glaptop>
	<1337720076.3361.667.camel@edumazet-glaptop>
	<1337766246.3361.2447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kmansley@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760641Ab2EWReH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 13:34:07 -0400
In-Reply-To: <1337766246.3361.2447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 May 2012 11:44:06 +0200

> Locking the socket for the whole operation (including copyout to user)
> is not very good. It was good enough years ago with small receive
> window.
> 
> With a potentially huge backlog, it means user process has to process
> it, regardless of its latency constraints. CPU caches are also
> completely destroyed because of huge amount of data included in thousand
> of skbs.

But it is the only way we can have TCP processing scheduled and
accounted to user processes.  That does have value when you have lots
of flows active.

The scheduler's ability to give the process cpu time influences
TCP's behavier, and under load if the process can't get enough
cpu time then TCP will back off.  We want that.
