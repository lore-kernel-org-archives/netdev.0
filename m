From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix bond_get_stats()
Date: Fri, 18 Mar 2016 23:15:06 -0400 (EDT)
Message-ID: <20160318.231506.825745828255522925.davem@davemloft.net>
References: <1458260616.31963.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	j.vosburgh@gmail.com, vfalico@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbcCSDPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 23:15:08 -0400
In-Reply-To: <1458260616.31963.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Mar 2016 17:23:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> bond_get_stats() can be called from rtnetlink (with RTNL held)
> or from /proc/net/dev seq handler (with RCU held)
> 
> The logic added in commit 5f0c5f73e5ef ("bonding: make global bonding
> stats more reliable") kind of assumed only one cpu could run there.
> 
> If multiple threads are reading /proc/net/dev, stats can be really
> messed up after a while.
> 
> A second problem is that some fields are 32bit, so we need to properly
> handle the wrap around problem.
> 
> Given that RTNL is not always held, we need to use
> bond_for_each_slave_rcu().
> 
> Fixes: 5f0c5f73e5ef ("bonding: make global bonding stats more reliable")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
