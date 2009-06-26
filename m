From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 22:19:32 +0200
Message-ID: <20090626201932.GB6908@ami.dom.local>
References: <19012.53943.734747.493480@robur.slu.se> <20090626151051.GA2714@ami.dom.local> <20090626153010.GC6771@linux.vnet.ibm.com> <20090626155410.GA6526@ami.dom.local> <20090626161500.GB6526@ami.dom.local> <20090626162340.GF6771@linux.vnet.ibm.com> <20090626164557.GB6755@ami.dom.local> <20090626170538.GK6771@linux.vnet.ibm.com> <20090626180544.GA6908@ami.dom.local> <20090626182143.GN6771@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:57874 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbZFZUTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:19:49 -0400
Received: by fxm9 with SMTP id 9so2317920fxm.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 13:19:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090626182143.GN6771@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 11:21:43AM -0700, Paul E. McKenney wrote:
> On Fri, Jun 26, 2009 at 08:05:45PM +0200, Jarek Poplawski wrote:
> > On Fri, Jun 26, 2009 at 10:05:38AM -0700, Paul E. McKenney wrote:
> > ...
> > > In that case, simply invoking synchronize_rcu() every once and awhile
> > > should take care of things.  This could be at the end of every large
> > > trie operation, or you could even count the call_rcu() invocations and
> > > do a synchronize_rcu() every 100th, 1,000th, or whatever, based on
> > > the amount of memory available.
> > 
> > OK, for now the minimal change for testing (2.6.30 needs previously
> > mentioned two commits from 2.6.31-rc). (I guess I'll send it with a
> > changelog after net-next is opened.)
> 
> Looks promising to me!!!
> 

Alas, after rethinking, there is one detail which bothers me. Those
largest allocs here are done with vmalloc and freed with RCU by
schedule_work(). So, I wonder if just because of this, the previous
version doing it directly isn't more reliable anyway. Of course, it's
my bad I didn't point it while describing the problem earlier. (I knew
I missed something...;-)

Thanks,
Jarek P.
