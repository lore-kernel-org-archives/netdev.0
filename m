From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: fix l2tp_eth module loading
Date: Thu, 28 Sep 2017 17:14:10 +0200
Message-ID: <20170928151410.jmsvdcdr6h3xlffg@alphalink.fr>
References: <a7d351fd5948fc69ef17da3c170cd7c152f899c4.1506606179.git.g.nault@alphalink.fr>
 <20170928141728.GA3107@jackdaw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51523 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbdI1POS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:14:18 -0400
Content-Disposition: inline
In-Reply-To: <20170928141728.GA3107@jackdaw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 03:17:28PM +0100, Tom Parkin wrote:
> On Thu, Sep 28, 2017 at 03:44:38PM +0200, Guillaume Nault wrote:
> > The l2tp_eth module crashes if its netlink callbacks are run when the
> > pernet data aren't initialised.
> > 
> > We should normally register_pernet_device() before the genl callbacks.
> > However, the pernet data only maintain a list of l2tpeth interfaces,
> > and this list is never used. So let's just drop pernet handling
> > instead.
> > 
> > Fixes: d9e31d17ceba ("l2tp: Add L2TP ethernet pseudowire support")
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> 
> Whoops.  I think this was intended to clear up the devices in the net
> namespace,
Yes, that's what I thought too. That's what virtual devices are
supposed to do and think I'll eventually implement this at a later
time.

> but since l2tp_core.c already deletes tunnels on namespace
> exit I don't think it's necessary for l2tp_eth.c to do anything more.
> 
Well, removing l2tpeth devices is just a side effect of closing the
tunnel. But the tunnel may be in a different namespace than the device,
in case the later was moved after creation. In this case, the l2tpeth
interface isn't deleted when its namespace is destroyed. It's moved
to the initial namespace instead (because, for now, l2tpeth devices
don't implement ->rtnl_link_ops).

These are shortcomings I'd like to fix, but there are more important
issues to tackle first.
