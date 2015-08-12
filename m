From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Tue, 11 Aug 2015 18:13:49 -0700
Message-ID: <20150812011347.GA58200@Alexeis-MacBook-Pro.local>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <20150729210618.GF32705@breakpoint.cc>
 <20150729213428.GC15554@orbit.nwl.cc>
 <20150729.143731.834219016906219771.davem@davemloft.net>
 <20150811174807.3e00b4da@redhat.com>
 <20150811162335.GB32353@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, cwang@twopensource.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36549 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932855AbbHLBNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 21:13:53 -0400
Received: by ioeg141 with SMTP id g141so5490524ioe.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 18:13:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150811162335.GB32353@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 06:23:35PM +0200, Phil Sutter wrote:
> 
> I have an unfinished solution in the oven, but being kept busy with
> other things for now. The action plan is as follows:
> 
> 1) Introduce IFF_NO_QUEUE net_device->priv_flag.
> 2) Have attach_default_qdiscs() and attach_one_default_qdisc() treat
>    IFF_NO_QUEUE as alternative to tx_queue_len == 0.
> 3) Add warning to register_netdevice() if tx_queue_len == 0.
> 4) Change virtual NIC drivers to set IFF_NO_QUEUE and leave tx_queue_len
>    alone.
> 5) Eventually drop all special handling for tx_queue_len == 0.
> 
> I am currently somewhere in 2) and need to implement 4) for veth as PoC to
> check if 2) suffices in all situations we want. Not sure if 3) is
> desireable at all or if there are valid cases for a literally zero
> length TX queue length.

sounds like you want to change default qdisc from pfifo_fast to noqueue
for veth, right?
In general 'changing the default' may be an acceptable thing, but then
it needs to strongly justified. How much performance does it bring?
Also why introduce the flag? Why not just add 'tx_queue_len = 0;' 
to veth_setup() like the whole bunch of devices do?
