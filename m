From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [bisected] e341694e3eb5 netlink_lookup() rcu conversion causes
 latencies
Date: Mon, 20 Oct 2014 10:21:08 +0200
Message-ID: <20141020082107.GB4268@osiris>
References: <20141011083627.GB5074@osiris>
 <1413055964.9362.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141011222514.GA14186@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	paulmck@linux.vnet.ibm.com,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ursula Braun <braunu@de.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:34908 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbaJTIVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 04:21:15 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Mon, 20 Oct 2014 09:21:13 +0100
Content-Disposition: inline
In-Reply-To: <20141011222514.GA14186@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2014 at 11:25:14PM +0100, Thomas Graf wrote:
> On 10/11/14 at 12:32pm, Eric Dumazet wrote:
> > On Sat, 2014-10-11 at 10:36 +0200, Heiko Carstens wrote:
> > > Hi all,
> > > 
> > > it just came to my attention that commit e341694e3eb5
> > > "netlink: Convert netlink_lookup() to use RCU protected hash table"
> > > causes network latencies for me on s390.
> > > 
> > > The testcase is quite simple and 100% reproducible on s390:
> > > 
> > > Simply login via ssh to a remote system which has the above mentioned
> > > patch applied. Any action like pressing return now has significant
> > > latencies. Or in other words, working via such a connection becomes
> > > a pain ;)
> > > 
> > > I haven't debugged it, however I assume the problem is that a) the
> > > commit introduces a synchronize_net() call und b) s390 kernels
> > > usually get compiled with CONFIG_HZ_100 while most other architectures
> > > use CONFIG_HZ_1000.
> > > If I change the kernel config to CONFIG_HZ_1000 the problem goes away,
> > > however I don't consider this a fix...
> > > 
> > > Another reason why this hasn't been observed on x86 may or may not be
> > > that we haven't implemented CONFIG_HAVE_CONTEXT_TRACKING on s390 (yet).
> > > But that's just guessing...
> > 
> > CC Paul and Sasha
> 
> I think the issue here is obvious and a fix is on the way to move
> the insertion and removal to a worker to no longer require the
> synchronize_rcu().
> 
> What bothers me is that the synchronize_rcu() should only occur
> on expand/shrink and not for every table update. The default table
> size is 64.

*ping* ... is there already any patch available?
