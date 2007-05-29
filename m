From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Tue, 29 May 2007 09:14:15 -0700
Message-ID: <20070529091415.03a14216@freepuppy>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070526.164418.115928217.davem@davemloft.net>
	<Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
	<20070527.021104.74747736.davem@davemloft.net>
	<Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
	<20070527140430.GA30299@galon.ev-en.org>
	<Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Baruch Even <baruch@ev-en.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:38817 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbXE2QUM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 12:20:12 -0400
In-Reply-To: <Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 May 2007 13:27:03 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Sun, 27 May 2007, Ilpo J=C3=A4rvinen wrote:
>=20
> > On Sun, 27 May 2007, Baruch Even wrote:
> >=20
> > > * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070527 14:16]:
> > > >=20
> > > > Thus, my original question basically culminates in this: should=
 cc
> > > > modules be passed number of packets acked or number of skbs ack=
ed?
> > > > ...The latter makes no sense to me unless the value is intented=
 to
> > > > be interpreted as number of timestamps acked or something along=
 those=20
> > > > lines. ...I briefly tried looking up for documentation for cc m=
odule=20
> > > > interface but didn't find anything useful about this, and thus =
asked in=20
> > > > the first place...
> > >=20
> > > At least the htcp module that I wrote assumes that the number is =
actual
> > > number of tcp packets so GSO should be considered.
> >=20
> > Thanks for the info! It is what I suspected... ...I'll write a patc=
h for=20
> > it tomorrow against net-2.6... Dave, beware that it will partially=20
> > overlap with the changes made in the patch 8, so you might choose t=
o put=20
> > the patch 8 on hold until this issue is first resolved...
> >=20
> > > The consequences of this bug are not too large but it does make a=
ll
> > > congestion control algorithms a lot less aggressive. On my machin=
es GSO
> > > is disabled by default (e1000 at 100mbps & Tigon3 @ 1Gbps).
> >=20
> > Agreed, that's my impression too. However, some algorithms do thing=
s
> > like > 0 checks for it, so it might disturb their dynamics even mor=
e
> > than in the "too small value" cases...
>=20
> Hmm, there seems to be another case that I'm not too sure of...
> Please check the alternative I choose for SYN handling below...
>=20
> ...hmm... While exploring this SYN thingie, I noticed that commit=20
> 164891aadf1721fca4dce473bb0e0998181537c6 drops !FLAG_RETRANS_DATA_ACK=
ED=20
> check from rtt_sample call (when combining it with pkts_acked call).
> I hope that's intentional?!? ...the commit message didn't say anythin=
g=20
> about it nor was anything in cc modules changed to accomodate that.
>=20
>=20
> [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl module=
s)
>=20
> The code used to ignore GSO completely, passing either way too
> small or zero pkts_acked when GSO skb or part of it got ACKed.
> In addition, there is no need to calculate the value in the loop
> but simple arithmetics after the loop is sufficient.

Yes, thanks for fixing this. Wonder how it affects measurements.
=20
> It is not very clear how SYN segments should be handled, so I
> choose to follow the previous implementation in this respect.

Since we don't invoke congestion control modules until after the SYN
handshake this is not a problem.


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
