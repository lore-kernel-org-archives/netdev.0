From: David Miller <davem@davemloft.net>
Subject: Re: [bisected] e341694e3eb5 netlink_lookup() rcu conversion causes
 latencies
Date: Sat, 11 Oct 2014 19:08:29 -0400 (EDT)
Message-ID: <20141011.190829.876705206204533685.davem@davemloft.net>
References: <20141011083627.GB5074@osiris>
	<1413055964.9362.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141011222514.GA14186@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, heiko.carstens@de.ibm.com,
	sasha.levin@oracle.com, paulmck@linux.vnet.ibm.com,
	nikolay@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, braunu@de.ibm.com
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141011222514.GA14186@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 11 Oct 2014 23:25:14 +0100

> I think the issue here is obvious and a fix is on the way to move
> the insertion and removal to a worker to no longer require the
> synchronize_rcu().
> 
> What bothers me is that the synchronize_rcu() should only occur
> on expand/shrink and not for every table update. The default table
> size is 64.

Not true, every netlink socket release incurs a synchronize_net()
now, because we added such a call to netlink_release().

I specifically brought this up to as a possible problem when the
changes went in...
