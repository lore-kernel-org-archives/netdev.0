From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Thu, 13 Nov 2008 14:19:01 -0800 (PST)
Message-ID: <20081113.141901.08693191.davem@davemloft.net>
References: <20081112.035240.226243372.davem@davemloft.net>
	<20081112.041143.11487260.davem@davemloft.net>
	<1226567412.6834.80.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752141AbYKMWTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 17:19:01 -0500
In-Reply-To: <1226567412.6834.80.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Thu, 13 Nov 2008 10:10:12 +0100

> On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 12 Nov 2008 03:52:40 -0800 (PST)
> > 
> > > Ok, Jesper, please try two things for me, leave the debugging patch
> > > in there for all the tests:
> > > 
> > > 1) Retrigger the problem (with or without MSI, doesn't matter) but
> > >    add back in that test I asked you to try last week.  The one
> > >    where the "if (++rp->mark_counter == rp->mark_freq)" condition
> > >    test in niu_start_xmit() is commented out, so that the
> > >    "mrk |= TX_DESC_MARK;" statement always runs.
> > > 
> > >    Get me the log dump produced by that scenerio.
> 
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x21e/0x230()
> NETDEV WATCHDOG: eth2 (niu): transmit timed out
> Modules linked in: niu ipmi_si hpwdt serio_raw bnx2 zlib_inflate rng_core ipmi_msghandler hpilo ehci_hcd uhci_hcd sr_mod cdrom
> Pid: 0, comm: swapper Not tainted 2.6.28-rc4-davem #17
> Call Trace:

Thanks a lot for making this test Jesper, even though the bug
is fixed.

> niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] CHANNEL 5 LDN 37
> niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] parent->lgd_map[ldn] 2
> niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] Num pending TX SKBs: 237
> niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] TX_CS sw[00ed00ec00000000] hw[00ed00ec00000000]

Same signature, counters advancing yet no mark bits are set.

Now if we can fix that MSIX BUG() and start analyzing your
pps performance with oprofile, we'll be in good shape :)
