From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Wed, 05 Oct 2011 02:11:27 -0400
Message-ID: <6.2.5.6.2.20111005020421.03a9e6c0@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Joe Perches <joe@perches.com>, Christoph Lameter <cl@gentwo.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>,
	Con Kolivas <kernel@kolivas.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gremlins!

In my haste I overlooked that changing the
thread pool from 140 to 13 is radical,
especially with a core count matching
the thread count.  Apples and oranges.

Ran the small-pool test on the other two
kernels and here are the results.  The
user and system columns are in jiffies.

kernel          total      user   system
2.6.18(rhel5)   02:07:16  615516  148152 (19.4%)
2.6.39.4        02:27:44  658074  228420 (25.7%)
2.6.39.4(bfs)   02:34:49  899936   29000 (3%)

So BFS performs somewhat worse than the default
scheduler on total-CPU.  The old RHEL 5 kernel
is still the winner, but not by nearly as
much in the small thread-pool scenario--.39
is only 16% slower than .18 with the
system overhead being 55% worse rather
than 100% worse.

So all that is shown after all is that
the differential between the older and
newer kernels is strongly influenced by
the number of active threads, and the O(N)
aspect of BFS makes it an inappropriate
choice for heavy multithreaded workloads.

Also small thread pools are more efficient
than large ones (especially when the workflow
is routed for optimal cache locality as
is the case here).  However the small
pool does not scale as well to maximum CPU
load as the large pool (a different test)
which is why it is no longer used in
production and was only dusted off
in order to enable the BFS comparison.
