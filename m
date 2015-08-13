From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Thu, 13 Aug 2015 17:06:48 +0200
Message-ID: <20150813150648.GG32353@orbit.nwl.cc>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <20150729210618.GF32705@breakpoint.cc>
 <20150729213428.GC15554@orbit.nwl.cc>
 <20150729.143731.834219016906219771.davem@davemloft.net>
 <20150811174807.3e00b4da@redhat.com>
 <20150811162335.GB32353@orbit.nwl.cc>
 <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
 <20150813011339.GF32353@orbit.nwl.cc>
 <20150813151033.048d73b8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:33059 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbbHMPGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 11:06:50 -0400
Content-Disposition: inline
In-Reply-To: <20150813151033.048d73b8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 03:10:33PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Thu, 13 Aug 2015 03:13:40 +0200 Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Tue, Aug 11, 2015 at 06:13:49PM -0700, Alexei Starovoitov wrote:
> 
> > > In general 'changing the default' may be an acceptable thing, but then
> > > it needs to strongly justified. How much performance does it bring?
> > 
> > A quick test on my local VM with veth and netperf (netserver and veth
> > peer in different netns) I see an increase of about 5% of throughput
> > when using noqueue instead of the default pfifo_fast.
> 
> Good that you can show 5% improvement with a single netperf flow.  We
> are saving approx 6 atomic operations avoiding the qdisc code path.
> 
> This fixes a scalability issue with veth. Thus, the real performance
> boost will happen with multiple flows and multiple CPU cores in
> action.  You can try with a multi core VM and use super_netperf.
> 
> https://github.com/borkmann/stuff/blob/master/super_netperf

I actually used that on my VM as well, but the difference between a
single and ten streams in parallel was negligible. In order to avoid
tampering the results, I tested again on a physical system with four
cores, ran each benchmark ten times and built an average over the
results. This showed an increase in throughput of about 35% with a
single stream and about 10% with ten streams in parallel. Not sure
though why the improvement is bigger in the first case if there really
is a scalability problem as you say.

Cheers, Phil
