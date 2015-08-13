From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Thu, 13 Aug 2015 03:13:40 +0200
Message-ID: <20150813011339.GF32353@orbit.nwl.cc>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <20150729210618.GF32705@breakpoint.cc>
 <20150729213428.GC15554@orbit.nwl.cc>
 <20150729.143731.834219016906219771.davem@davemloft.net>
 <20150811174807.3e00b4da@redhat.com>
 <20150811162335.GB32353@orbit.nwl.cc>
 <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60253 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbbHMBNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 21:13:47 -0400
Content-Disposition: inline
In-Reply-To: <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 06:13:49PM -0700, Alexei Starovoitov wrote:
> On Tue, Aug 11, 2015 at 06:23:35PM +0200, Phil Sutter wrote:
> > 
> > I have an unfinished solution in the oven, but being kept busy with
> > other things for now. The action plan is as follows:
> > 
> > 1) Introduce IFF_NO_QUEUE net_device->priv_flag.
> > 2) Have attach_default_qdiscs() and attach_one_default_qdisc() treat
> >    IFF_NO_QUEUE as alternative to tx_queue_len == 0.
> > 3) Add warning to register_netdevice() if tx_queue_len == 0.
> > 4) Change virtual NIC drivers to set IFF_NO_QUEUE and leave tx_queue_len
> >    alone.
> > 5) Eventually drop all special handling for tx_queue_len == 0.
> > 
> > I am currently somewhere in 2) and need to implement 4) for veth as PoC to
> > check if 2) suffices in all situations we want. Not sure if 3) is
> > desireable at all or if there are valid cases for a literally zero
> > length TX queue length.
> 
> sounds like you want to change default qdisc from pfifo_fast to noqueue
> for veth, right?
> In general 'changing the default' may be an acceptable thing, but then
> it needs to strongly justified. How much performance does it bring?
> Also why introduce the flag? Why not just add 'tx_queue_len = 0;' 
> to veth_setup() like the whole bunch of devices do?

A quick test on my local VM with veth and netperf (netserver and veth
peer in different netns) I see an increase of about 5% of throughput
when using noqueue instead of the default pfifo_fast.

Cheers, Phil
