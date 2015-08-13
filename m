From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len
 configurable
Date: Thu, 13 Aug 2015 15:10:33 +0200
Message-ID: <20150813151033.048d73b8@redhat.com>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
	<20150729210618.GF32705@breakpoint.cc>
	<20150729213428.GC15554@orbit.nwl.cc>
	<20150729.143731.834219016906219771.davem@davemloft.net>
	<20150811174807.3e00b4da@redhat.com>
	<20150811162335.GB32353@orbit.nwl.cc>
	<20150812011347.GA58200@Alexeis-MacBook-Pro.local>
	<20150813011339.GF32353@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org, brouer@redhat.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbbHMNKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 09:10:34 -0400
In-Reply-To: <20150813011339.GF32353@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 13 Aug 2015 03:13:40 +0200 Phil Sutter <phil@nwl.cc> wrote:

> On Tue, Aug 11, 2015 at 06:13:49PM -0700, Alexei Starovoitov wrote:

> > In general 'changing the default' may be an acceptable thing, but then
> > it needs to strongly justified. How much performance does it bring?
> 
> A quick test on my local VM with veth and netperf (netserver and veth
> peer in different netns) I see an increase of about 5% of throughput
> when using noqueue instead of the default pfifo_fast.

Good that you can show 5% improvement with a single netperf flow.  We
are saving approx 6 atomic operations avoiding the qdisc code path.

This fixes a scalability issue with veth. Thus, the real performance
boost will happen with multiple flows and multiple CPU cores in
action.  You can try with a multi core VM and use super_netperf.

https://github.com/borkmann/stuff/blob/master/super_netperf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
