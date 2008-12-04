From: David Miller <davem@davemloft.net>
Subject: Re: Realtek 8169 problems with net booting
Date: Thu, 04 Dec 2008 12:59:43 -0800 (PST)
Message-ID: <20081204.125943.211288136.davem@davemloft.net>
References: <200812041722.26935.mbrown@fensystems.co.uk>
	<20081204.101503.154423248.davem@davemloft.net>
	<200812042045.00773.mbrown@fensystems.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: mbrown@fensystems.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754874AbYLDU7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:59:43 -0500
In-Reply-To: <200812042045.00773.mbrown@fensystems.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Brown <mbrown@fensystems.co.uk>
Date: Thu, 4 Dec 2008 20:45:00 +0000

> On Thursday 04 December 2008 18:15:03 David Miller wrote:
> > > The assumption that the chip is quiescent is invalid in the case of any
> > > kind of boot from SAN (e.g. iSCSI, AoE) via the net device.  The
> > > INT13-based bootloader has no way to signal to the boot firmware that it
> > > is finished using the INT13 interface, so the card will always be left in
> > > an active state.
> >
> > So there is no "close" method for the boot loader to call?
> > Who designs this crud? :-(
> 
> I believe that would be IBM, circa 1980.  Pity they didn't consider the needs 
> of iSCSI boot in a protected-mode OS.

So we started with crap....

> For SAN boot, the network boot loader (e.g. gPXE) emulates a BIOS disk using 
> INT 13, and the next-stage boot loader (e.g. lilo/grub) believes that it is 
> operating a physical disk; it doesn't even know that there's a NIC involved 
> that may need to be shut down.

...and instead of adding the necessary facilities, things got built on
top of that crap.

So instead of having a real usable solution propagated widely within
a few years, we'll instead still be stuck with this stuff.

It rediculious to blame IBM for this, don't you think? :)  When
interfaces become outdated by technology, you make new ones.

> From our point of view, we will guarantee that the card is left in a
> state that is "active but harmless"; if the OS never touches the
> card then nothing bad will happen.  The driver should, as its first
> action, reset everything except the chip's PCI core.  (Some chips
> have only the facility to reset everything including the PCI core;
> I've seen drivers that back up PCI config space prior to reset and
> restore it afterwards, which seems to work.)

Yes, but don't expect this to be handled properly across the board in
any significant set of drivers any time soon.  Just about every one
I checked turns on bus mastering before doing anything else.
