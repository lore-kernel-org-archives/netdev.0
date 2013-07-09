From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 14:40:41 -0700
Message-ID: <20130709144041.0000045f@unknown>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
	<D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
	<20130709170242.GA14112@amd.pavel.ucw.cz>
	<1373390146.4286.1.camel@ppwaskie-mobl2>
	<20130709204854.GA21438@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42247 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063Ab3GIVkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 17:40:42 -0400
In-Reply-To: <20130709204854.GA21438@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Jul 2013 22:48:54 +0200
Pavel Machek <pavel@ucw.cz> wrote:

> Yeah, of course you need to ask e1000e if it generated the
> interrupt. That part works. The part that actually generates the
> interrupt does not. Take a look at original mail...
> 
> packet comes
> e1000e sets E1000_ICR_INT_ASSERTED bit
> e1000e tries to generate an interrupt and fails
> 50msec passes

^^ thats the ASPM timeout length.

> AHCI generates interrupt
> all the handlers are called
>     AHCI processes its interrupt, handles disk read
>     e1000_intr notices E1000_ICR_INT_ASSERTED bit, delivers the packet.
> 
> Network still works, only slowly. Ping goes lower when I use the
> disk. That matches what I see.
> 
> Do you have other explanation?

Regardless of what others are saying I believe you have an issue with
ASPM being enabled.  All the discussion about shared interrupts, is
just a distraction.  This issue would still occur (and just be worse)
without a shared interrupt.

You already mentioned that a kernel hack to disable ASPM fixes it, but
you can just boot with different options to turn off ASPM.

pcie_aspm=off

There are known issues with ASPM on this part, and it definitely needs
to be off.  If your bios has the option to turn it off, that is the
best way to disable it, second choice is to turn it off using the
kernel option.

Hope this helps,
Jesse
