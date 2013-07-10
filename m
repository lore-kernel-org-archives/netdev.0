From: Pavel Machek <pavel@ucw.cz>
Subject: Re: e1000e on thinkpad x60: interrupt problem
Date: Wed, 10 Jul 2013 13:37:43 +0200
Message-ID: <20130710113742.GA9113@amd.pavel.ucw.cz>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
 <D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
 <20130709170242.GA14112@amd.pavel.ucw.cz>
 <1373390146.4286.1.camel@ppwaskie-mobl2>
 <20130709204854.GA21438@amd.pavel.ucw.cz>
 <20130709144041.0000045f@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:38468 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373Ab3GJLho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 07:37:44 -0400
Content-Disposition: inline
In-Reply-To: <20130709144041.0000045f@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> > Yeah, of course you need to ask e1000e if it generated the
> > interrupt. That part works. The part that actually generates the
> > interrupt does not. Take a look at original mail...
> > 
> > packet comes
> > e1000e sets E1000_ICR_INT_ASSERTED bit
> > e1000e tries to generate an interrupt and fails
> > 50msec passes
> 
> ^^ thats the ASPM timeout length.
> 
> > AHCI generates interrupt
> > all the handlers are called
> >     AHCI processes its interrupt, handles disk read
> >     e1000_intr notices E1000_ICR_INT_ASSERTED bit, delivers the packet.
> > 
> > Network still works, only slowly. Ping goes lower when I use the
> > disk. That matches what I see.
> > 
> > Do you have other explanation?
> 
> Regardless of what others are saying I believe you have an issue with
> ASPM being enabled.  All the discussion about shared interrupts, is
> just a distraction.  This issue would still occur (and just be worse)
> without a shared interrupt.

Agreed.

> You already mentioned that a kernel hack to disable ASPM fixes it, but
> you can just boot with different options to turn off ASPM.
> 
> pcie_aspm=off

Are you sure? AFAICT linux will not turn off aspm if ACPI says
so.. hence the hack. 

# From: Robert Hancock <hancockrwd@gmail.com>
# To: Pavel Machek <pavel@ucw.cz>
# CC: Greg KH <greg@kroah.com>, kernel list
# <linux-kernel@vger.kernel.org>,
#         joe.lawrence@stratus.com, myron.stowe@redhat.com,
#         bhelgaas@google.com
# Subject: Re: /sys/module/pcie_aspm/parameters/policy not writable?
# ...
# > pavel@amd:~$ dmesg | grep -i aspm
# > ACPI FADT declares the system doesn't support PCIe ASPM, so disable
# it
# 
# IIRC, this message is somewhat misleading. When that FADT flag is set
# by the BIOS, the kernel doesn't so much disable ASPM as disable the
# kernel's control over ASPM. I believe this was to match Windows
# behavior.

It looks like ASPM needs to be off, but BIOS enables ASPM and tells
kernel it is not supported... and that means that kernel will not
disable it :-(.

I guess there's no way to do ASPM disable for single device from the
driver?

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
