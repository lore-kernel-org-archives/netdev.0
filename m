From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Sat, 01 Nov 2014 01:30:11 +0000
Message-ID: <1414805411.16849.104.camel@decadent.org.uk>
References: <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CF9D1877D81D214CB0CA0669EFAE020C68CA2FAA@CMEXMB1.ad.emulex.com>
	 <1414004996.9031.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141022.161402.119032019463935567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-A7CA1SCAS4VRuXZUD50V"
Cc: eric.dumazet@gmail.com, Sathya.Perla@Emulex.Com,
	netdev@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55318 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756643AbaKABaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 21:30:21 -0400
In-Reply-To: <20141022.161402.119032019463935567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-A7CA1SCAS4VRuXZUD50V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-22 at 16:14 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 22 Oct 2014 12:09:56 -0700
>=20
> > On Wed, 2014-10-22 at 18:35 +0000, Sathya Perla wrote:
> >> Agree. Are you suggesting that drivers should automatically
> >> register an XPS configuration? I thought it was upto the user
> >> to enable it...
> >=20
> > Yep, search for netif_set_xps_queue()
> >=20
> > (commit 537c00de1c9ba9876b9)
> >=20
> > Look at commit d03a68f8217ea0349 for an example of how it can be done,
> > if user do not override this later.
>=20
> Very few people know about this :-/
>=20
> I only see 4 drivers adjusted to do this, it would be nice if this
> was more widespread.

It seems to require that the driver also sets IRQ affinity hints, which
I've never been very comfortable with.  Drivers either set queue n =3D CPU
n without regard for topology, or optimise for whichever
micro-architecture the vendor most cares about.  irqbalance then
slavishly follows these hints, so we have each driver (rather than the
administrator) setting policy.

Alternately the driver could create an irq_cpu_rmap for its TX interupts
and that could be used to select queues based on current affinity
(<http://thread.gmane.org/gmane.linux.network/186698>).  But we already
seem to have too many ways to do TX queue selection.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-A7CA1SCAS4VRuXZUD50V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFQ3pOe/yOyVhhEJAQoMDhAAn2/t3mUJ2KR3m0fXG4JH1BrWvt03JGwq
dPOhL3u/J1n5F1I9hNj+mTVAClwe1vBUn9okrlGuRxlQIZorMRrF3xw0X2t3mbST
2q7T+8D5iZqabNXqOVwvYMrUDfERkC8/x5pK0h2HoCWImLGboxlnINdFtyeAVHj2
6Q8FoDUiA4UEE+k4NrroNdpbS7ijSz/8iaH6p12IYtX1tUNoJxu4d1plBP5BNScM
h93EJM6ALEcywzu0h35YRS6XnLRXRc0MIheOKfZNNG1l6TpPZsyYHu04r2rZTa5g
gAtivTD2AtjpoUizo+4oAkLeQHE73Xh16j5cE0j/LZB4mdKdIZQ7sYacjJyRPMo0
XnmmoWcVBoiIfc2IU44jZ5Y3kjy29qJHS42Wq9WzPMe95rzseujZZRZn1CTsCVeX
mN0lmXPL2MpVf+YJnYoGPc3mkrgW0R+11gQqHtthtH61fbWjsJBdsqAiXEk+aHxz
lwDUYqlqk21OMjVjeMKSCEn/rJnilAWtfEJyeSNIq49y4Mfq5rbttauXHjOMKmEq
3vvyivQljroqzUDv74PmsXZbYU7qNEa1BZTEMHg696Xkd0+Dgv6iNVgwc3f9H1oN
Zx9cPwnhuFQiRsyoM1VIZRbrbpcSaqeqls/kzRsLZ708ztp1I6FhPUr6QXgipi00
zhNP9fsNt1c=
=Sjai
-----END PGP SIGNATURE-----

--=-A7CA1SCAS4VRuXZUD50V--
