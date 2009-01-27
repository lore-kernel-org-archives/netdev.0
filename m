From: "Narnakaje, Snehaprabha" <nsnehaprabha@ti.com>
Subject: RE: [patch 2.6.28-rc8-davinci-git] dm355: dm9000
Date: Mon, 26 Jan 2009 22:51:22 -0600
Message-ID: <7A436F7769CA33409C6B44B358BFFF0CFC0385FA@dlee02.ent.ti.com>
References: <7A436F7769CA33409C6B44B358BFFF0CFC0384D1@dlee02.ent.ti.com>
 <20090126235834.GA24162@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57684 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644AbZA0EwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 23:52:06 -0500
In-Reply-To: <20090126235834.GA24162@fluff.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Ben Dooks [mailto:ben-linux@fluff.org]
> Sent: Monday, January 26, 2009 6:59 PM
> To: Narnakaje, Snehaprabha
> Cc: netdev@vger.kernel.org
> Subject: Re: [patch 2.6.28-rc8-davinci-git] dm355: dm9000
> 
> On Mon, Jan 26, 2009 at 04:36:50PM -0600, Narnakaje, Snehaprabha wrote:
> > Hi,
> >
> > I am having an issue with the dm9000 driver on a DaVinci DM355 based
> platform.
> >
> > I configure dm9000 to get an IP address through dhcp and then mount via
> NFS. I get the following dump, just after getting an IP Address and trying
> to connect to the NFS server.
> >
> > ------------[ cut here ]------------
> > WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x188/0x2a0()
> > NETDEV WATCHDOG: eth0 (dm9000): transmit timed out
> > Modules linked in:
> > [<c002c890>] (dump_stack+0x0/0x14) from [<c003b81c>]
> (warn_slowpath+0x64/0x80)
> > [<c003b7b8>] (warn_slowpath+0x0/0x80) from [<c01bf934>]
> (dev_watchdog+0x188/0x2a0)
> >  r3:c6c81800 r2:c02af9a4
> >  r6:c02ce000 r5:c6c81800 r4:c030d710
> > [<c01bf7ac>] (dev_watchdog+0x0/0x2a0) from [<c00459b4>]
> (run_timer_softirq+0x1bc/0x278)
> > [<c00457f8>] (run_timer_softirq+0x0/0x278) from [<c0040a44>]
> (__do_softirq+0x74/0x110)
> > [<c00409d0>] (__do_softirq+0x0/0x110) from [<c0040e74>]
> (irq_exit+0x50/0xa0)
> > [<c0040e24>] (irq_exit+0x0/0xa0) from [<c0028068>]
> (__exception_text_start+0x68/0x84)
> >  r4:00000020
> > [<c0028000>] (__exception_text_start+0x0/0x84) from [<c0028a28>]
> (__irq_svc+0x48/0x88)
> > Exception stack(0xc02cff40 to 0xc02cff88)
> > ff40: 00000000 0005317f 0005217f 60000013 c0029e80 c02ce000 c02d1e44
> c0029e80
> > ff60: c02e82a4 41069265 80020e54 c02cff94 600000d3 c02cff88 c0029ec4
> c0029ed0
> > ff80: 60000013 ffffffff
> >  r5:fec48000 r4:ffffffff
> > [<c0029e80>] (default_idle+0x0/0x58) from [<c0029d4c>]
> (cpu_idle+0x58/0x98)
> > [<c0029cf4>] (cpu_idle+0x0/0x98) from [<c022cb9c>] (rest_init+0x68/0x7c)
> >  r8:80020ef0 r7:c02d1cd8 r6:c0022f0c r5:c02e7e4c r4:c02fd180
> > [<c022cb34>] (rest_init+0x0/0x7c) from [<c00089f0>]
> (start_kernel+0x260/0x2c0)
> > [<c0008790>] (start_kernel+0x0/0x2c0) from [<80008034>] (0x80008034)
> >  r5:c02e8354 r4:00053175
> > ---[ end trace a0edb9581ce81991 ]---
> >
> >
> > As per the details below, this happens only if I use spinlock/spinunlock
> sequence in dm9000_start_xmit(). If I change this to dm9000 specific
> disable/enable interrupts, I do see the above dump and platform comes up
> fine with NFS.
> >
> > Any ideas?
> 
> The spin lock sequence already disables the IRQs over the transmit. We
> cannot allow the code to be re-entered either by another interrupt
> such as a watchdog timeout or receive interrupt.

We used to have dm9000 rx/tx enable/disable sequence in dm9000_start_xmit() of an earlier version of dm9000.c (2.6.18 to 2.6.22). Since 2.6.23 we moved to the spinlock sequence, probably for the watchdog timeout.

The spinlock sequence shows the watchdong timeout (dump above). Is it expected? Has it been reported earlier? 

I do not see this dump, if I revert back to the dm9000 rx/tx enable/disable sequence.

Thanks
Sneha

> 
> > Thanks a lot,
> > Sneha
> >
> >
> > -----Original Message-----
> > From: davinci-linux-open-source-
> bounces+nsnehaprabha=ti.com@linux.davincidsp.com [mailto:davinci-linux-
> open-source-bounces+nsnehaprabha=ti.com@linux.davincidsp.com] On Behalf Of
> Narnakaje, Snehaprabha
> > Sent: Tuesday, January 20, 2009 7:38 PM
> > To: Kevin Hilman; David Brownell
> > Cc: davinci-linux-open-source@linux.davincidsp.com
> > Subject: RE: [patch 2.6.28-rc8-davinci-git] dm355: mmc0 works for pio
> >
> > David, Kevin,
> >
> > Here is an update on the DM9000 issue.
> >
> > I spent some time on debugging DM9000 issue - "tx timeout and a kernel
> crash".
> >
> > In the current version of dm9000 driver (1.3), the hard_start_xmit API
> for DM9000 - dm9000_start_xmiit() uses spin_lock_irqsave(&db->lock,
> flags); to disable the interrupts, before accessing/setting DM9000 TX
> registers. It also calls spin_unlock_irqrestore(&db->lock, flags); after
> initiating a tx.
> >
> > In an older version of the dm9000.c (1.2 from kernel 2.6.18 to 2.6.22)
> we just disabled dm9000 rx/tx interrupts by writing to the dm9000 register
> and enabled them after initiating the tx.
> >
> > It does look like, dm9000 stopped receiving the tx interrupts (at least
> dm9000_interrupt is not getting called for tx completion) and thus we
> starting seeing tx timeout from the netdev.
> >
> > I can get NFS working, if I change the spin_lock/spin_unlock function
> calls to dm9000 specific rx/tx interrupt disable/enable functions.
> >
> > I believe, dm9000 specific rx/tx interrupt functions were replaced by
> the spin_lock/spin_unlock functions to a fix a hang problem under heavy
> load.
> >
> > I will continue to debug this further, wanted to see, if you have any
> inputs in this area.
> >
> > I did not see this issue being reported on the netdev kernel.org mailing
> list, so not sure, if there is a DM355 specific irq initialization we have
> missed.
> >
> > Thanks
> > Sneha
> >
> > > -----Original Message-----
> > > From: davinci-linux-open-source-bounces@linux.davincidsp.com
> > > [mailto:davinci-linux-open-source-bounces@linux.davincidsp.com] On
> Behalf
> > > Of Kevin Hilman
> > > Sent: Friday, December 19, 2008 11:01 AM
> > > To: David Brownell
> > > Cc: davinci-linux-open-source@linux.davincidsp.com
> > > Subject: Re: [patch 2.6.28-rc8-davinci-git] dm355: mmc0 works for pio
> > >
> > > David Brownell <david-b@pacbell.net> writes:
> > >
> > > > On Thursday 18 December 2008, Kevin Hilman wrote:
> > > >> Strange. ?I get NETDEV WATCHDOG timeouts whether I try to mount
> over
> > > >> NFS, or whether I simply ssh from a MMC rootfs to linux box. ?This
> is
> > > >> with current davinci git head. ?Have I missed any of your patches?
> > > >
> > > > Nothing related to the dm9000 or AEMIF, it seems.  Does using
> > > >
> > > >   CONFIG_DM9000_FORCE_SIMPLE_PHY_POLL=y
> > > >
> > > > change things?
> > > >
> > >
> > > Nope.
> > >
> > > Kevin
> > >
> > >
> > >
> > >
> > > _______________________________________________
> > > Davinci-linux-open-source mailing list
> > > Davinci-linux-open-source@linux.davincidsp.com
> > > http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
> > _______________________________________________
> > Davinci-linux-open-source mailing list
> > Davinci-linux-open-source@linux.davincidsp.com
> > http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Ben (ben@fluff.org, http://www.fluff.org/)
> 
>   'a smiley only costs 4 bytes'

