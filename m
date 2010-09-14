From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use rcu_barrier() in rollback_registered_many
Date: Tue, 14 Sep 2010 14:27:49 -0700 (PDT)
Message-ID: <20100914.142749.55853240.davem@davemloft.net>
References: <4C8A3430.2070105@6wind.com>
	<1284128679.24675.38.camel@edumazet-laptop>
	<1284416694.2627.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	opurdila@ixiacom.com, bcrl@kvack.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752930Ab0INV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:27:30 -0400
In-Reply-To: <1284416694.2627.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Sep 2010 00:24:54 +0200

> [PATCH] net: use rcu_barrier() in rollback_registered_many
> 
> netdev_wait_allrefs() waits that all references to a device vanishes.
> 
> It currently uses a _very_ pessimistic 250 ms delay between each probe.
> Some users reported that no more than 4 devices can be dismantled per
> second, this is a pretty serious problem for some setups.
> 
> Most of the time, a refcount is about to be released by an RCU callback,
> that is still in flight because rollback_registered_many() uses a
> synchronize_rcu() call instead of rcu_barrier(). Problem is visible if
> number of online cpus is one, because synchronize_rcu() is then a no op.
> 
> time to remove 50 ipip tunnels on a UP machine :
> 
> before patch : real 11.910s
> after patch : real 1.250s
> 
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reported-by: Octavian Purdila <opurdila@ixiacom.com>
> Reported-by: Benjamin LaHaise <bcrl@kvack.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
