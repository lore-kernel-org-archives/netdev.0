From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 08:53:43 +0200
Message-ID: <1224917623.4929.15.camel@marge.simson.net>
References: <20081010115725.GD19487@elte.hu>
	 <200810250025.35734.rjw@sisk.pl>
	 <1224905848.5161.27.camel@marge.simson.net>
	 <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59836 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752000AbYJYGxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 02:53:47 -0400
In-Reply-To: <1224914333.3822.18.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-25 at 07:58 +0200, Mike Galbraith wrote:
> On Fri, 2008-10-24 at 22:16 -0700, David Miller wrote:

> > If not, please bisect this.
> 
> (oh my <fword> gawd:)
> 
> I spent long day manweeks trying to bisect and whatnot.  It's immune to
> my feeble efforts, and my git-foo.

but..

(tbench/netperf numbers were tested with gcc-4.1 at this time in log, I
went back and re-measured ring-test because I switched compilers)

2.6.22.19-up
ring-test   - 1.204 us/cycle  = 830 KHz  (gcc-4.1)
ring-test   - doorstop                   (gcc-4.3)
netperf     - 147798.56 rr/s  = 295 KHz  (hmm, a bit unstable, 140K..147K rr/s)
tbench      - 374.573 MB/sec

2.6.22.19-cfs-v24.1-up
ring-test   - 1.098 us/cycle  = 910 KHz  (gcc-4.1)
ring-test   - doorstop                   (gcc-4.3)
netperf     - 140039.03 rr/s  = 280 KHz = 3.57us - 1.10us sched = 2.47us/packet network
tbench      - 364.191 MB/sec

2.6.23.17-up
ring-test   - 1.252 us/cycle  = 798 KHz  (gcc-4.1)
ring-test   - 1.235 us/cycle  = 809 KHz  (gcc-4.3)
netperf     - 123736.40 rr/s  = 247 KHz  sb 268 KHZ / 134336.37 rr/s
tbench      - 355.906 MB/sec

2.6.23.17-cfs-v24.1-up
ring-test   - 1.100 us/cycle  = 909 KHz  (gcc-4.1)
ring-test   - 1.074 us/cycle  = 931 KHz  (gcc-4.3)
netperf     - 135847.14 rr/s  = 271 KHz  sb 280 KHz / 140039.03 rr/s
tbench      - 364.511 MB/sec

2.6.24.7-up
ring-test   - 1.100 us/cycle  = 909 KHz  (gcc-4.1)
ring-test   - 1.068 us/cycle  = 936 KHz  (gcc-4.3)
netperf     - 122300.66 rr/s  = 244 KHz  sb 280 KHz / 140039.03 rr/s
tbench      - 341.523 MB/sec

2.6.25.17-up
ring-test   - 1.163 us/cycle  = 859 KHz  (gcc-4.1)
ring-test   - 1.129 us/cycle  = 885 KHz  (gcc-4.3)
netperf     - 132102.70 rr/s  = 264 KHz  sb 275 KHz / 137627.30 rr/s
tbench      - 361.71 MB/sec

..in 25, something happened that dropped my max context switch rate from
~930 KHz to ~885 KHz.  Maybe I'll have better luck trying to find that.
Added to to-do list.  Benchmark mysteries I'm going to have to leave
alone, they've kicked my little butt quite thoroughly ;-)

	-Mike

