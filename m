From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Tue, 29 May 2007 13:19:51 -0700
Message-ID: <20070529131951.1d9a5b84@freepuppy>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070526.164418.115928217.davem@davemloft.net>
	<Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
	<20070527.021104.74747736.davem@davemloft.net>
	<Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
	<20070527140430.GA30299@galon.ev-en.org>
	<Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
	<20070529091415.03a14216@freepuppy>
	<Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Even <baruch@ev-en.org>, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:41384 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758244AbXE2U2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 16:28:36 -0400
In-Reply-To: <Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 23:07:00 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Tue, 29 May 2007, Stephen Hemminger wrote:
>=20
> > On Mon, 28 May 2007 13:27:03 +0300 (EEST)
> > "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> >=20
> > > On Sun, 27 May 2007, Ilpo J=C3=A4rvinen wrote:
> > >=20
> > > [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl mo=
dules)
> >=20
> > Yes, thanks for fixing this. Wonder how it affects measurements.
>=20
> ...It's a bit hard to tell since dynamics change so dramatically=20
> in > 0 check cases, the resulting behavior in too small value cases
> may be easier to predict... It's possible that this could explain som=
e=20
> anomalities you've been seeing in your measurements.
>=20
> > > It is not very clear how SYN segments should be handled, so I
> > > choose to follow the previous implementation in this respect.
> >=20
> > Since we don't invoke congestion control modules until after the SY=
N
> > handshake this is not a problem.
>=20
> Just curious, do you mean that cc modules cannot measure, e.g., initi=
al
> RTT through this mechanism (though they could do that in init() cb th=
en
> I suppose)... Or do you mean that they are called already for the ACK
> that completes the SYN handshake and therefore its skb is being clean=
ed=20
> from the queue right now (this is the case I above refer to)?=20
> In the first case the decrementer code is NOP. If the latter, then it
> is just interface specification question, i.e., if SYNs are treated a=
s=20
> zero or one in num_acked for the pkts_acked callback (I have no opini=
on
> on this but was just trying to make sure cc modules get what they
> expect :-)).=20

We don't switch a socket out of Reno until after the initial handshake.
It evolved that way, and has a couple of advantages:
 * uncomplete connections don't up module refcount so it is easier to
   debug
 * in future, we can choose congestion control to use based on route
   metric.
=20
As an interface, it makes sense to keep the API with the SYN counting
as a packet.

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
