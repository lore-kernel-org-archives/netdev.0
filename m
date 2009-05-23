From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 13:03:31 -0400
Message-ID: <1243098211.4217.9.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <4A0C7443.1010000@googlemail.com>
	 <1243042174.3580.23.camel@obelisk.thedillows.org>
	 <200905231124.28925.mb@bu3sch.de>  <4A1809B0.3030109@googlemail.com>
	 <1243090308.4217.6.camel@obelisk.thedillows.org>
	 <4A182066.9030201@googlemail.com>
	 <1243097173.4217.7.camel@obelisk.thedillows.org>
	 <4A182A08.9050305@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:59256 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472AbZEWRDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 13:03:32 -0400
In-Reply-To: <4A182A08.9050305@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-23 at 18:53 +0200, Michael Riepe wrote:
> 
> David Dillow wrote:
> > On Sat, 2009-05-23 at 18:12 +0200, Michael Riepe wrote:
> > 
> >>If I use two connections (iperf -P2) and nail iperf to both threads of a
> >>single core with taskset (the program is multi-threaded, just in case
> >>you wonder), I get this:
> >>
> >>CPU 0+2:  0.0-60.0 sec  4.65 GBytes    665 Mbits/sec
> >>CPU 1+3:  0.0-60.0 sec  6.43 GBytes    920 Mbits/sec
> >>
> >>That's quite a difference, isn't it?
> >>
> >>Now I wonder what CPU 0 is doing...
> > 
> > 
> > Where does /proc/interrupts say the irqs are going?
> 
> Oh well...

>  27:   48463995          0          0          0   PCI-MSI-edge      eth0

What does it look like if you move the iperf around the CPUs while using
pci=nomsi? 

I'm looking to make sure I didn't cause a terrible regression in the
cost of IRQ handling...

