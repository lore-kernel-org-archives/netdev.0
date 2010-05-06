From: dormando <dormando@rydia.net>
Subject: Re: 3 packet TCP window limit?
Date: Thu, 6 May 2010 01:51:24 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1005060131110.28957@d>
References: <alpine.LNX.2.00.1005050210230.8544@d>  <4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d>  <4BE1D3B0.9000207@hp.com> <alpine.LNX.2.00.1005051421010.28957@d> <0C1FD143-5588-4455-B08F-85ADD19E0E02@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, Brian Bloniarz <bmb@athenacr.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Eggert <lars.eggert@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([216.218.163.68]:35795 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113Ab0EFIvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 04:51:24 -0400
In-Reply-To: <0C1FD143-5588-4455-B08F-85ADD19E0E02@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 2010-5-5, at 23:31, dormando wrote:
> > The RFC clearly states "around 4k",
>
> no, it doesn't. RFC3390 gives a very precise formula for calculating the initial window:
>
> 	min (4*MSS, max (2*MSS, 4380 bytes))
>
> Please see the RFC for why. More reading at http://www.icir.org/floyd/tcp_init_win.html I believe that Linux implements behavior this pretty faithfully.

Sorry, paraphrasing :) Web nerds have been working around this for a long
time now. Google talks about using HTTP chunked encoding responses to send
an initial "frame" of a webpage in under 3 packets. Which immediately
gives the browser something to render and primes the TCP connection for
more web junk.

> I'm surprised to hear that OpenBSD doesn't follow the RFC. Can you share a measurement? Are you sure the box you are measuring is using the default configuration?

Yeah, default config. OBSD was giving me back 4 packets in the first
window, while linux always gives back 3. The Big/IP is based on linux
2.4.21. If that kernel didn't have it wrong, they tuned it.

Already nuked my dumps. If you're curious I'll re-create.

> I don't think the RFC can be misread (it's pretty clear), and the
> formula is also not exactly complicated. My guess would be that some
> vendors have convinced themselves that using a slightly larger value is
> OK, esp. if they can show customers that "their" TCP is "faster" than
> some competitors' TCPs. An arms race between vendors in this space would
> really not be good for anyone - it's clear that at some point, problems
> due to overshoot will occur.

I clearly remember some vendors bragging about doing this. That was a long
time ago? Perhaps they stopped? If it's true they've been doing it for
half a decade or more, and haven't broken anything someone would notice.

The only reason why I set about tuning this is because our latency jumped
while moving traffic from a commercial machine to a linux machine, and I
had to figure out what they changed to do that. I've since turned the
setting *back* to the standard, having confirmed what they did.

Almost tempted to test this against a bunch of websites...

> (We can definitely argue about whether the current RFC-recommended value
> is too low, and Google and others are gathering data in support of
> making a convincing and backed-up argument for increasing the initial
> window to the IETF. Which is exactly the correct way of going about
> this.)

This sounds like fun. We have some diverse traffic, so I'm hoping we can
contribute to that conversation. Still have a lot of reading to catch up
with first :)
