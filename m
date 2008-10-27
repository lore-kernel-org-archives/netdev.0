From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 11:42:50 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>
References: <20081024.221653.23695396.davem@davemloft.net> <1224914333.3822.18.camel@marge.simson.net> <1224917623.4929.15.camel@marge.simson.net> <20081025.002420.82739316.davem@davemloft.net> <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
 <1225010790.8566.22.camel@marge.simson.net> <1225011648.27415.4.camel@twins> <20081026021153.47878580.akpm@linux-foundation.org> <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50382 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751406AbYJ0Kmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 06:42:51 -0400
In-Reply-To: <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008, Jiri Kosina wrote:

> > > > > 208.4 MB/sec  -- vanilla 2.6.16.60
> > > > > 201.6 MB/sec  -- vanilla 2.6.20.1
> > > > > 172.9 MB/sec  -- vanilla 2.6.22.19
> > > > > 74.2 MB/sec   -- vanilla 2.6.23
> > > > >  46.1 MB/sec  -- vanilla 2.6.24.2
> > > > >  30.6 MB/sec  -- vanilla 2.6.26.1
> > > > > I.e. huge drop for 2.6.23 (this was with default configs for each 
> > > > > respective kernel).
> > Was this when we decreased the default value of
> > /proc/sys/vm/dirty_ratio, perhaps?  dbench is sensitive to that.
> 2.6.28 gives 41.8 MB/s with /proc/sys/vm/dirty_ratio == 50. So small 
> improvement, but still far far away from the throughput of pre-2.6.23 
> kernels.

Ok, so another important datapoint:

with c1e4fe711a4 (just before CFS has been merged for 2.6.23), the dbench 
throughput measures

	187.7 MB/s

in our testing conditions (default config).

With c31f2e8a42c4 (just after CFS has been merged for 2.6.23), the 
throughput measured by dbench is

	82.3 MB/s

This is the huge drop we have been looking for. After this, the 
performance was still going down gradually, up to ~45 MS/ we are measuring 
for 2.6.27. But the biggest drop (more than 50%) points directly to CFS 
merge.

-- 
Jiri Kosina
SUSE Labs
