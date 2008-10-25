From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 01:10:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
References: <20081024.221653.23695396.davem@davemloft.net>
 <1224914333.3822.18.camel@marge.simson.net> <1224917623.4929.15.camel@marge.simson.net>
 <20081025.002420.82739316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: efault@gmx.de, rjw@sisk.pl, Ingo Molnar <mingo@elte.hu>,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:54653 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756528AbYJYXK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 19:10:58 -0400
In-Reply-To: <20081025.002420.82739316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Oct 2008, David Miller wrote:

> But note that tbench performance improved a bit in 2.6.25.
> In my tests I noticed a similar effect, but from 2.6.23 to 2.6.24,
> weird.
> Just for the public record here are the numbers I got in my testing.

I have been currently looking at very similarly looking issue. For the 
public record, here are the numbers we have been able to come up with so 
far (measured with dbench, so the absolute values are slightly different, 
but still shows similar pattern)

208.4 MB/sec  -- vanilla 2.6.16.60
201.6 MB/sec  -- vanilla 2.6.20.1
172.9 MB/sec  -- vanilla 2.6.22.19
74.2 MB/sec   -- vanilla 2.6.23
 46.1 MB/sec  -- vanilla 2.6.24.2
 30.6 MB/sec  -- vanilla 2.6.26.1

I.e. huge drop for 2.6.23 (this was with default configs for each 
respective kernel).
2.6.23-rc1 shows 80.5 MB/s, i.e. a few % better than final 2.6.23, but 
still pretty bad. 

I have gone through the commits that went into -rc1 and tried to figure 
out which one could be responsible. Here are the numbers:

 85.3 MB/s for 2ba2d00363 (just before on-deman readahead has been merged)
 82.7 MB/s for 45426812d6 (before cond_resched() has been added into page 
187.7 MB/s for c1e4fe711a4 (just before CFS scheduler has been merged)
                           invalidation code)

So the current bigest suspect is CFS, but I don't have enough numbers yet 
to be able to point a finger to it with 100% certainity. Hopefully soon.

Just my $0.02

-- 
Jiri Kosina
SUSE Labs

