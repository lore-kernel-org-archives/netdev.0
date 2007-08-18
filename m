From: Willy Tarreau <w@1wt.eu>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sat, 18 Aug 2007 07:38:12 +0200
Message-ID: <20070818053812.GP6002@1wt.eu>
References: <424491.59139.qm@web38906.mail.mud.yahoo.com> <20070817170341.7f2645fa@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1736 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbXHRFpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 01:45:54 -0400
Content-Disposition: inline
In-Reply-To: <20070817170341.7f2645fa@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2007 at 05:03:41PM -0700, Stephen Hemminger wrote:
> On Fri, 17 Aug 2007 05:42:13 -0700 (PDT)
> Kevin E <kevin360@yahoo.com> wrote:
> 
> > Hi all,
> > 
> > 	I've read where the onboard Marvell lan controller on
> > some Gigabyte boards don't work.  I've got two systems
> > using the same Gigabyte board, on one the LAN works on
> > the other it dies like described by others.  Here's
> > the systems:
> > 
> > 
> > Working system:
> > Gigabyte 965P-DS3 rev 3.3  (BIOS F10)
> > Core2 Q6600
> > 2GB Corsair XMS2 memory
> > kernel 2.6.22.3
> > 
> > lspci for LAN controller:
> > 04:00.0 Ethernet controller: Marvell Technology Group
> > Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev
> > 14)
> > 
> > 
> > Broken system:
> > Gigabyte 965P-DS3 rev 3.3  (BIOS F10)
> > Core2 E4400
> > 2GB Corsair XMS2 memory
> > kernel 2.6.22.3
> > 
> > lspci for LAN controller:
> > 03:00.0 Ethernet controller: Marvell Technology Group
> > Ltd. Unknown device 4364 (rev 12)
> > 
> > 
> > 	The BIOS for the two systems are setup the same and
> > the config for the kernels are the same too.  I've
> > actually tried taking the kernel from the working
> > system and booting it on the broken one but still the
> > LAN dies after a couple of seconds.  The working
> > system has one card plugged in (nvidia based PCI-X
> > video card), I've taken that card and plugged into the
> > broken system, booted the same kernel, and it still
> > dies after a while.
> > 
> > 	I will gladly provide any info needed if it can help
> > in getting this chipset working on the Gigabyte
> > boards.
> > 
> > 	Thanks,
> > 	Kevin
> 
> I maintain the sky2 driver, and have one of the (buggy) Gigabyte motherboards.
> It is interesting that the problem seems to track with video card.

No Stephen, look again, he says that moving the video card into the broken
system does not change anything.

> Are you using the Nvidia binary driver?
> The video card in the system I have troubles with is:
> 	ATI Technologies Inc RV370 [Radeon X300SE]
> 
> Surprisingly, using other PCI-E cards with same driver (different Marvell chips)
> has no problem.  Vendor version of sk98lin driver has same failure mode
> on the buggy hardware.
> 
> You might want to look at lspci -vvv output on two system to see if there
> are differences. Perhaps there is a CPU speed dependency?

I don't understand why the working one is on PCI bus 3 while the other
is on PCI bus 4. It's just as if the chip embedded a PCI bridge. Maybe
those chips are just cheaper dual-channel controllers with one faulty
controller disabled. It would also explain why the PCI ID is different.

Willy

