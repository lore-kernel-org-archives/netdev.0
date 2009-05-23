From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 10:51:48 -0400
Message-ID: <1243090308.4217.6.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <4A0C7443.1010000@googlemail.com>
	 <1243042174.3580.23.camel@obelisk.thedillows.org>
	 <200905231124.28925.mb@bu3sch.de>  <4A1809B0.3030109@googlemail.com>
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
Received: from smtp.knology.net ([24.214.63.101]:36612 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752226AbZEWOvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 10:51:48 -0400
In-Reply-To: <4A1809B0.3030109@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-23 at 16:35 +0200, Michael Riepe wrote:
> Hi!
> 
> Michael Buesch wrote:
> 
> > Thanks a lot, Dave! This fixes the issue on my chip.
> 
> Yep, it's stable here as well. And even a little faster than pci=nomsi.
> The only strangeness I observed is that the throughput (measured with
> iperf and a single TCP connection) varies:
> 
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec    667 MBytes    559 Mbits/sec
> [  3] 10.0-20.0 sec    803 MBytes    673 Mbits/sec
> [  3] 20.0-30.0 sec    802 MBytes    673 Mbits/sec
> [  3] 30.0-40.0 sec    714 MBytes    599 Mbits/sec
> [  3] 40.0-50.0 sec    669 MBytes    561 Mbits/sec
> [  3] 50.0-60.0 sec    791 MBytes    663 Mbits/sec
> [  3]  0.0-60.0 sec  4.34 GBytes    622 Mbits/sec
> 
[snip]
> I suppose it's a side effect of the MSI acknowledgement loop. But who am
> I to complain about higher average throughput? ;-)

I wonder if that is the TCP sawtooth pattern -- run up until we drop
packets, drop off, repeat. I thought newer congestion algorithms would
help with that, but I've not kept up, this may be another red-herring --
like the bisection into genirq.

A tcpdump may answer the question -- wireshark can do an analysis and
see if it is running up until it starts dropping or something.

Or it may be the loop, but I wouldn't expect it to make such a big
difference, or be as variable if it does.

Also, what does it look like with multiple streams?

Thanks for testing guys -- I'm glad it works for a sample size > 1!

Dave

