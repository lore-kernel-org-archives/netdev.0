From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] common receive API + r8169 use
Date: Tue, 2 Aug 2011 23:43:49 +0200
Message-ID: <20110802214349.GA17411@rere.qmqm.pl>
References: <f85e6be597ae30fd4dab776b924c0cd0a66514c0.1312314817.git.mirq-linux@rere.qmqm.pl>
 <20110802141500.3c99185b@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60805 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab1HBVnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 17:43:51 -0400
Content-Disposition: inline
In-Reply-To: <20110802141500.3c99185b@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 02, 2011 at 02:15:00PM -0700, Stephen Hemminger wrote:
> On Tue,  2 Aug 2011 22:24:35 +0200 (CEST)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > Here is a preliminary version of common RX path for network drivers=
=2E The idea
> > is an extension to Eric Dumazet's patch introducing build_skb() (it=
's
> > incorporated here for easier testing).
> >=20
> > Future plans:
> >  - extend this API to devices which can do split buffer receives co=
rrectly
> >    and use napi_gro_frags() instead;
> >  - implement DaveM's idea of RX buffer handling (fill first, proces=
s
> >    if buffers available) in parallel to my version (process first, =
refill
> >    later);
> >  - get rid of indirect calls in fast path (process_buffer() and
> >    add_buffer()) - ideas? inline netdev_rx_poll() and pass callback=
 to it?
> >=20
> > Version rebased on v3.0 is running succesfully on one laptop with r=
8169 on
> > board since about a week. No problems showed up yet. For net-next t=
his
> > needs retesting because of changes in device reset handling.
>=20
> 1. Don't put #ifdef code in, just go with the new code.

I have a patch that removes old code. I left it out for now to make rev=
iew
of the main code easier.

> 2. Get rid of the inline on all those functions. Anything over 3 line=
s
>    really shouldn't be inlined.

I plan to move most of those functions to dev.c later. For the receive
processing hot path (netdev_rx_poll), inlining won't add much code to
running kernel (I expect most systems use single or at most a few drive=
rs
at once), but will allow the compiler to optimize out function calls fr=
om
the inner loop.

> 3. What is the performance difference (if any)?

I don't have fast enough transmitter yet, so have no real data. Eric's
testing showed dramatic reduction in CPU usage after changing igb to us=
e
build_skb().  Inlined version of this patch should give similar results=
=2E

Eric: can you share the igb changes? I have no hardware for it, but cou=
ld
merge our changes for you to test.

Best Regards,
Micha=B3 Miros=B3aw
