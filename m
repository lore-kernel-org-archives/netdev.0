From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 17 Apr 2007 14:36:12 +0200
Message-ID: <20070417123612.GB1976@ff.dom.local>
References: <20070403065810.GA1832@ff.dom.local> <Pine.LNX.4.64.0704031618070.3963@sheep.housecafe.de> <20070404112100.GA1979@ff.dom.local> <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de> <Pine.LNX.4.64.0704061852270.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de, Francois Romieu <romieu@fr.zoreil.com>
To: Christian Kujau <christian@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:55442 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753895AbXDQMal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 08:30:41 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704061852270.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 06, 2007 at 07:19:25PM +0100, Christian Kujau wrote:
> On Wed, 4 Apr 2007, Christian Kujau wrote:
> >>Maybe it's a real locking problem. Here are some more
> >>suggestions for testing (if you don't find anything better):
> >>- try without SMP, so: 'acpi=off lapic nosmp'
> 
> We were able to have our hosting provider to replace the 8139too with a 
> E100, the onboard r8169 stayed of course. After this, the box came back 
> fine...only to lock up again shortly after :(
> 
> So again we spoke to our hosting provider and they just took out the 2 
> SATA disks and put them in a completely new system: amd64 dualcore 
> again, 2 GB ram, r8169 onboard NIC, e100 pci-slot NIC. Now booting 
> 2.6.20.4 and even 2.6.18-4-k7 (the debian kernel) with IOAPIC eabled 
> seems to work, meaning the box is up since yesterday evening and 
> interrupts are shared. Not equally, but still:
> 
> # cat /proc/interrupts
>            CPU0       CPU1
...
>  16:        157     575579   IO-APIC-fasteoi   eth0
>  17:    3812553          1   IO-APIC-fasteoi   eth1
...

Yes! Nobody can deny they are shared. It's a miracle they
don't lockup now!

> While this is a good thing, we now have different problems: our 2nd sata 
> drive is not usable any more, but we again we doubt hardware problems, 
> because this disk has been replaced already back in the old box...
> 
> but yes, this seem to be different problems, for the curious among 
> you I've put details here: http://nerdbynature.de/bits/2.6.20.4/db2/

I don't want to waste your time for experiments, so don't
feel obliged to respond or try this all, but here are
some impressions - what I'd do:

- these disk errors look serious and there is no reason
to try anything else without removing such disk and
testing it in some other place,

- the configs are changed, but they sometimes include many
"risky" options like: X86_MCE, HOTPLUG, ACPI_BATTERY,
ACPI_BUTTON, ACPI_PROCESSOR, ENABLE_MEMORY_HOTPLUG etc.;
I doubt you need IDE at all: probably SATA_VIA and PATA_VIA
should be enough for your disks; with such problems I'd start
with absolute minimum - and no drivers for other models
(BTW - maybe I'm wrong, but isn't AMD64 MK-8?),

- if, with some config, a lockup is expected soon, I'd
turn off any watchdogs, turn on many debugging - e.g.
lockdep, and try to wait and get some oops during a lockup
(sometime it needs a few minutes, sometime SYSRQ is helpful);
without this you could never be sure it'll work or your
hardware would work at half speed with unnecessarily
turned off options.

> Thanks to all who have replied,

And I thank you for cooperation and interesting problems.
But I doubt anybody here is satisfied with anything but:
"it's working" (and your hardware doesn't look so special
it shouldn't work).

Cheers,
Jarek P.
