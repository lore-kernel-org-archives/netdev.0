From: Jerry Chu <hkchu@google.com>
Subject: Re: 3 packet TCP window limit?
Date: Thu, 6 May 2010 16:15:52 -0700
Message-ID: <k2od1c2719f1005061615ne3778916j28b5348cd4ddce6f@mail.gmail.com>
References: <alpine.LNX.2.00.1005050210230.8544@d>
	 <4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d>
	 <4BE1D3B0.9000207@hp.com> <alpine.LNX.2.00.1005051421010.28957@d>
	 <0C1FD143-5588-4455-B08F-85ADD19E0E02@nokia.com>
	 <alpine.LNX.2.00.1005060131110.28957@d>
	 <p2h349f35ee1005061513x1db24de0ld98a40256c481ac2@mail.gmail.com>
	 <q2ud1c2719f1005061613yf90cd7c6r46ee23cc49858e74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lars Eggert <lars.eggert@nokia.com>,
	Rick Jones <rick.jones2@hp.com>,
	Brian Bloniarz <bmb@athenacr.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:10389 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab0EFXPy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 19:15:54 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o46NFr5U016676
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 16:15:53 -0700
Received: from ywh13 (ywh13.prod.google.com [10.192.8.13])
	by wpaz17.hot.corp.google.com with ESMTP id o46NFqwT011786
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 16:15:52 -0700
Received: by ywh13 with SMTP id 13so292044ywh.8
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 16:15:52 -0700 (PDT)
In-Reply-To: <q2ud1c2719f1005061613yf90cd7c6r46ee23cc49858e74@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: dormando <dormando@rydia.net>
>
> Date: Thu, May 6, 2010 at 1:51 AM
> Subject: Re: 3 packet TCP window limit?
> To: Lars Eggert <lars.eggert@nokia.com>
> Cc: Rick Jones <rick.jones2@hp.com>, Brian Bloniarz
> <bmb@athenacr.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>
>
> > On 2010-5-5, at 23:31, dormando wrote:
> > > The RFC clearly states "around 4k",
> >
> > no, it doesn't. RFC3390 gives a very precise formula for calculatin=
g the initial window:
> >
> > =A0 =A0 =A0 min (4*MSS, max (2*MSS, 4380 bytes))
> >
> > Please see the RFC for why. More reading at http://www.icir.org/flo=
yd/tcp_init_win.html I believe that Linux implements behavior this pret=
ty faithfully.
>
> Sorry, paraphrasing :) Web nerds have been working around this for a =
long
> time now. Google talks about using HTTP chunked encoding responses to=
 send
> an initial "frame" of a webpage in under 3 packets. Which immediately
> gives the browser something to render and primes the TCP connection f=
or
> more web junk.
>
> > I'm surprised to hear that OpenBSD doesn't follow the RFC. Can you =
share a measurement? Are you sure the box you are measuring is using th=
e default configuration?
>
> Yeah, default config. OBSD was giving me back 4 packets in the first
> window, while linux always gives back 3. The Big/IP is based on linux
> 2.4.21. If that kernel didn't have it wrong, they tuned it.
>
> Already nuked my dumps. If you're curious I'll re-create.
>
> > I don't think the RFC can be misread (it's pretty clear), and the
> > formula is also not exactly complicated. My guess would be that som=
e
> > vendors have convinced themselves that using a slightly larger valu=
e is
> > OK, esp. if they can show customers that "their" TCP is "faster" th=
an
> > some competitors' TCPs. An arms race between vendors in this space =
would
> > really not be good for anyone - it's clear that at some point, prob=
lems
> > due to overshoot will occur.
>
> I clearly remember some vendors bragging about doing this. That was a=
 long
> time ago? Perhaps they stopped? If it's true they've been doing it fo=
r
> half a decade or more, and haven't broken anything someone would noti=
ce.
>
> The only reason why I set about tuning this is because our latency ju=
mped
> while moving traffic from a commercial machine to a linux machine, an=
d I
> had to figure out what they changed to do that. I've since turned the
> setting *back* to the standard, having confirmed what they did.
>
> Almost tempted to test this against a bunch of websites...
>
> > (We can definitely argue about whether the current RFC-recommended =
value
> > is too low, and Google and others are gathering data in support of
> > making a convincing and backed-up argument for increasing the initi=
al
> > window to the IETF. Which is exactly the correct way of going about
> > this.)
>
> This sounds like fun. We have some diverse traffic, so I'm hoping we =
can
> contribute to that conversation. Still have a lot of reading to catch=
 up
> with first :)

Yes please do.=A0 Our presentation at Anaheim IETF can be found at
http://www.ietf.org/proceedings/10mar/slides/tcpm-4.pdf, with a paper d=
escribing
the details of our experiments at
http://code.google.com/speed/articles/tcp_initcwnd_paper.pdf.

We've gotten a lot of feedback from IETF and are planning to collect
more data to
justify the proposal. But at this point we really need help from
others as the scope of
the work is certainly not a one-company job. Help can be in the form of=
 more
experiments/tests and/or simulations to study the effect of a larger
initcwnd. Please
contact me directly or send your data to IETF's TCPM WG list
(http://www.ietf.org/mail-archive/web/tcpm/current/maillist.html).

Thanks,

Jerry
