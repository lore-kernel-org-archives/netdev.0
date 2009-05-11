From: David Dillow <dave@thedillows.org>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Mon, 11 May 2009 17:29:52 -0400
Message-ID: <1242077392.3716.15.camel@lap75545.ornl.gov>
References: <200903041828.49972.m.bueker@berlin.de>
 <1242001754.4093.12.camel@obelisk.thedillows.org>
 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute3.ornl.gov ([160.91.4.110]:60193 "EHLO emroute3.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359AbZEKWAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 18:00:14 -0400
In-reply-to: <200905112310.08534.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-11 at 23:10 +0200, Michael Buesch wrote:
> On Monday 11 May 2009 22:48:44 Michael Buesch wrote:
> > On Monday 11 May 2009 02:29:14 David Dillow wrote:
> > > > Kernel: 2.6.29.2 (x86_64)
> > > > Board: Intel D945GCLF2
> > > > BIOS version: LF94510J.86A.0099.2008.0731.0303
> > > 
> > > I'm not sure this is tied to the chip. 
> > 
> > Yeah maybe other chips are affected as well.
> > I just want to note that my failing chip/board is an Intel D945GCLF2 board
> > with onboard G-LAN, too.
> > 
> > The device XID is: XID 3c4000c0
> > (see kernel log)
> > 
> > Somebody else (I think it was Rui Santos) already reported a failing chip with that XID, too.
> > 
> 
> Here's a patch which blacklists MSI support by XID.
> It's currently only compile-tested, because I can't reboot the machine right now.

I was saying that I don't think the timeouts are necessarily the NIC
chipset -- or the bridge chip for that matter --  having issues with
MSI. There were some substantial IRQ handling changes in 2.6.28 and my
bisection of the problem seem to lead into that code. I'll try this
later tonight hopefully, but can you try to run 2.6.27 with the current
r8169 driver and see if it is solid for you? That way it is using the
same driver code, but avoids the IRQ changes.

Of course, my XID is 281000c0, so it looks like I have a different NIC
chip as well, so we may be chasing different problems. Still, it'd be
nice to rule out the IRQ changes before adding a blacklist.

Dave
