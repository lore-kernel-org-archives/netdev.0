From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net 00/03]: dev_queue_xmit error propagation
Date: Thu, 11 Jun 2009 03:18:52 -0700 (PDT)
Message-ID: <20090611.031852.90563118.davem@davemloft.net>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754639AbZFKKSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:18:50 -0400
In-Reply-To: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  9 Jun 2009 18:16:59 +0200 (MEST)

> Currently the ->ndo_hard_start_xmit() callbacks are only permitted to return
> one of the NETDEV_TX codes. This prevents any kind of error propagation for
> virtual devices, like queue congestion of the underlying device in case of
> layered devices, or unreachability in case of tunnels.
> 
> These patches change the return conventions so hard_start_xmit() can return
> a NETDEV_TX code, an errno code or a NET_XMIT code. This means it can
> additionally to the NETDEV_TX codes simply return the value of dev_queue_xmit().
> 
> When queueing is used, errors can't be propagated back since transmission is
> asynchronously and all non-NETDEV codes are mapped to NETDEV_TX_OK, reflecting
> the fact that the skb is consumed unconditionally.
> 
> In case of virtual devices not using queueing, the NETDEV_TX codes are consumed
> by dev_queue_xmit(), everything else is returned to the higher layers.
> 
> The end result is that virtual network devices can propagate queue congestion
> state of the underlying device, or other errors, back to the socket layer.
> One immediately useful effect is that TCP can make use of this information
> as is currently done with non-virtual devices. But it also seems useful in case
> of tunnels, which can return more meaningful errors, or for statistics.
> 
> Comments welcome. A review of my changes in dev_hard_start_xmit() would be
> especially appreciated :)

These changes look fine to me.

That one if() conditional checking 'ret' for three different
properties is stretching the brain a bit.  Maybe you can
encapsulate that sucker into an inline function with suitable
comments.  That way when someone reads the test, it just says
what it is looking for, rather than being some complicated
set of tests.

Once you fix that up and the problem Eric spotted in patch #3
feel free to formally submit this.

Thanks!
