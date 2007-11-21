From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: skge ethernet breakage (PCI: Unable to reserve mem region)
Date: Wed, 21 Nov 2007 14:31:30 -0800
Message-ID: <20071121143130.07d1f5fd@freepuppy.rosehill>
References: <1189183355.3784.11.camel@localhost>
	<20070911102110.1f32fa7e@oldman>
	<1189508304.4069.5.camel@localhost>
	<20070911143701.628c8d18@oldman>
	<1189517941.4069.15.camel@localhost>
	<1190235469.4034.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Gukelberger <g.u.g.i@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50978 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751921AbXKUWbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 17:31:49 -0500
In-Reply-To: <1190235469.4034.77.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 22:57:49 +0200
Jan Gukelberger <g.u.g.i@gmx.de> wrote:

> Hi,
> 
> seems as if there are currently no more ideas?
> 
> So shall I perhaps open a bug in Kernel Bugzilla?
> 
> Thanks,
> Jan
> 
> On Tue, 2007-09-11 at 15:39 +0200, Jan Gukelberger wrote:
> > On Tue, 2007-09-11 at 14:37 +0200, Stephen Hemminger wrote:
> > > On Tue, 11 Sep 2007 12:58:24 +0200
> > > Jan Gukelberger <g.u.g.i@gmx.de> wrote:
> > > 
> > > > On Tue, 2007-09-11 at 10:21 +0200, Stephen Hemminger wrote:
> > > > > On Fri, 07 Sep 2007 18:42:35 +0200
> > > > > Jan Gukelberger <g.u.g.i@gmx.de> wrote:
> > > > [...]
> > > > > > The key problem seem to be the following lines in dmesg:
> > > > > > ------------------------------------------------------------------------
> > > > > > ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
> > > > > > PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
> > > > > > skge 0000:04:04.0: cannot obtain PCI resources
> > > > > > ACPI: PCI interrupt for device 0000:04:04.0 disabled
> > > > > > skge: probe of 0000:04:04.0 failed with error -16
> > > > > > ------------------------------------------------------------------------
> > > > > > 
> > > > > 
> > > > > There is some kind of device conflict, please provide lspci -vvvxx output.
> > > > 
> > > > I'm attaching the output of 'lspci -vvvxx' on the working 2.6.20 kernel
> > > > as well as the output of 'lspci -vvxxx' on 2.6.23-rc5 which I recorded
> > > > earlier.
> > > > I you specifically need 'lspci -vvvxx' on 2.6.23-rc5 please drop me a
> > > > note and I'll reboot quickly.
> > > > 
> > > > Thanks,
> > > > Jan
> > > 
> > > All looks in order, on the PCI tables. There is a firewire control just
> > > above the skge device, perhaps you enabled one of the firewire stacks
> > > in the configuration? 
> > 
> > I did a quick diff of the respective kernel .config's (this is the
> > configuration you mean, right?) and haven't found any notable
> > differences in the firewire options.
> > 
> > >  Perhaps the console (dmesg) output will show some clue.
> > 
> > I'm attaching a diff between dmesg of a working and a non-working boot.
> > You can find the full dmesg records in my first mail and in the Debian
> > BTS respectively.
> > 
> > The only thing I can see there is the old  kernel having some problems
> > with the SATA controller - even though I did never notice any unusual
> > behaviour apart from these messages:
> > ------------------------------------------------------------------------
> > PCI: Device 0000:02:00.0 not available because of resource collisions
> > ahci: probe of 0000:02:00.0 failed with error -22
> > JMB363: IDE controller at PCI slot 0000:02:00.0
> > PCI: Device 0000:02:00.0 not available because of resource collisions
> > ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> > JMB363: BIOS configuration fixed.
> > ------------------------------------------------------------------------
> > 
> > Don't know whether this could be related?
> > 
> > Thanks,
> > Jan
> 

The problem is in the tables (ACPI) from the BIOS. So ACPI
driver (and/or BIOS) have to work out the resource assignments,
the driver really has nothing to do with it.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
