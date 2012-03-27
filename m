From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a potential rcu_read_lock() imbalance in
 rt6_fill_node()
Date: Tue, 27 Mar 2012 18:22:08 -0400 (EDT)
Message-ID: <20120327.182208.806353341087563847.davem@davemloft.net>
References: <4F71EF2A.8020507@candelatech.com>
	<1332877149.3547.24.camel@edumazet-glaptop>
	<1332878032.3547.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, paulmck@linux.vnet.ibm.com,
	davej@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab2C0WWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 18:22:18 -0400
In-Reply-To: <1332878032.3547.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Mar 2012 21:53:52 +0200

> Commit f2c31e32b378 (net: fix NULL dereferences in check_peer_redir() )
> added a regression in rt6_fill_node(), leading to rcu_read_lock()
> imbalance.
> 
> Thats because NLA_PUT() can make a jump to nla_put_failure label.
> 
> Fix this by using nla_put()
> 
> Many thanks to Ben Greear for his help
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Great work everyone.

I'll apply this and queue it up for stable soon.

In other news, I think the days of hidden gotos from the NLA macros
should be over.  I'll work in net-next to redo this so that the
gotos must be explicitly coded and therefore be visible when people
audit these routines.

Thanks!
