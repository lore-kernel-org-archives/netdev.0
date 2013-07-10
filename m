From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [E1000-devel] e1000e on thinkpad x60: interrupt problem
Date: Wed, 10 Jul 2013 03:43:53 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD6527D939B@ORSMSX102.amr.corp.intel.com>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
	<D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
	<20130709170242.GA14112@amd.pavel.ucw.cz>
	<1373390146.4286.1.camel@ppwaskie-mobl2>
	<20130709204854.GA21438@amd.pavel.ucw.cz> <20130709144041.0000045f@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:41396 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754066Ab3GJDn4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 23:43:56 -0400
In-Reply-To: <20130709144041.0000045f@unknown>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latest kernel should turn off ASPM as well, but you should be able to check by looking at lspci -vvv. I think LnkCtl should say "ASPM disabled."

Sorry for top-posting.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565


-----Original Message-----
From: Jesse Brandeburg [mailto:jesse.brandeburg@intel.com] 
Sent: Tuesday, July 09, 2013 2:41 PM
To: Pavel Machek
Cc: e1000-devel@lists.sourceforge.net; Allan, Bruce W; Brandeburg, Jesse; Ronciak, John; netdev@vger.kernel.org
Subject: Re: [E1000-devel] e1000e on thinkpad x60: interrupt problem

On Tue, 9 Jul 2013 22:48:54 +0200
Pavel Machek <pavel@ucw.cz> wrote:

> Yeah, of course you need to ask e1000e if it generated the interrupt. 
> That part works. The part that actually generates the interrupt does 
> not. Take a look at original mail...
> 
> packet comes
> e1000e sets E1000_ICR_INT_ASSERTED bit e1000e tries to generate an 
> interrupt and fails 50msec passes

^^ thats the ASPM timeout length.

> AHCI generates interrupt
> all the handlers are called
>     AHCI processes its interrupt, handles disk read
>     e1000_intr notices E1000_ICR_INT_ASSERTED bit, delivers the packet.
> 
> Network still works, only slowly. Ping goes lower when I use the disk. 
> That matches what I see.
> 
> Do you have other explanation?

Regardless of what others are saying I believe you have an issue with ASPM being enabled.  All the discussion about shared interrupts, is just a distraction.  This issue would still occur (and just be worse) without a shared interrupt.

You already mentioned that a kernel hack to disable ASPM fixes it, but you can just boot with different options to turn off ASPM.

pcie_aspm=off

There are known issues with ASPM on this part, and it definitely needs to be off.  If your bios has the option to turn it off, that is the best way to disable it, second choice is to turn it off using the kernel option.

Hope this helps,
Jesse

------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics Get end-to-end visibility with application monitoring from AppDynamics Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
