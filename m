From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Sun, 10 Jan 2010 01:57:18 +0000
Message-ID: <1263088638.2480.210.camel@localhost>
References: <20100107010122.GA5872@electric-eye.fr.zoreil.com>
	 <20100106.171514.104051841.davem@davemloft.net>
	 <20100108234800.GA2908@electric-eye.fr.zoreil.com>
	 <20100108.160252.189352309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-YQM4b7DTazrjMQ7sSYqB"
Cc: romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34342 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752443Ab0AJB52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 20:57:28 -0500
In-Reply-To: <20100108.160252.189352309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YQM4b7DTazrjMQ7sSYqB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-01-08 at 16:02 -0800, David Miller wrote:
[...]
> Whilst the above will end up gobbling up to (16K - BIG_PACKET_SZ)
> worth of innocent frames, the DMA engine seems to keep things at least
> self-consistent.
>=20
> The only bug seems to be the omission of the LastFrag trigger at the
> proper place.

No, the attacker controls the completion status by writing it in
previous valid frames.  Please read the slides
(<http://events.ccc.de/congress/2009/Fahrplan/attachments/1483_26c3_ipv4_fu=
ckups.pdf> pages 80-87).

I suspect that:
1. There is an internal ring buffer for RX DMA containing both frame
payload and completion status
2. When a frame is (slightly?) over-length, the ingress and egress logic
can disagree about the length of payload in the buffer
3. This results in stale data (usually frame payload) being written to
memory as the completion status

It is conceivable that the bug can be avoided simply by rounding the=20
RxMaxSize.

[...]
> Therefore we shouldn't need to change anything and there is actually
> no "bug" or "exploit" at all.  We just end up dropping some RX frames
> because the chip didn't DMA them properly.

The intent of the exploit is precisely to cause other packets to be
dropped!

Ben.

--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers

--=-YQM4b7DTazrjMQ7sSYqB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS0kz8+e/yOyVhhEJAQKQkA//STmeTjhqfuE79kgX2BdF682uYYOfGgtS
yqvAr2qaC94pxR+RnQNWNSvs5ILUMTzxwEQTU1fHTIXEv9hzitGRSwNRRXbf9jRl
4VkesTduvjHwQHkibY3y7TOf9VWrXrgtJyesSG2LN5hCRT5XQGdsNcH71Hi2/Zn6
A776ciB2+IIrKAiKsnkYSjcYDq1S5PZJoEfgWVS4Ak2EUStGfl57E3XiuVsqF+LL
63bPIUbkZaOxhNtYdi0v4aQchM5CEh6XTbgLo5eM1cP0V4l2X+BtrU+CAuFRdOqQ
4+OSAntZ0rkTb4GEXJa8D6QfLdssPpy9o9UbcmrGRqm0NOJz2agViAreP/ANTpNH
xwxAjAFpXBhrJhfLQdO5OsT62UcgKT76neqcyp/0RRBtSgPh5n7eTg8VoniWlV/X
TupkloC/f60VRHBDcUIErg3aLpeslY5VirRnvBvJPqpM8Z7AYiwIIbpj3m1KMnrX
3qA/vomaMX52H/V8dcCGKNcPkv7dEye+dwQFRhcyYv9nFGMEIVH7no5E+ZOnXue+
t0tzrad3s9Ll4iCUg4vhuaJMw9s6T6PVs6JFbK2+eb+H0/hbL6ceXDkFr85Ou/8Q
3RvuecIi3JZ4CitJ89P5hkbILtaDTzu7sATbV/bt/icd8tOwQ1sPR/T2r3HttFVb
m8zm0pasybg=
=QGIx
-----END PGP SIGNATURE-----

--=-YQM4b7DTazrjMQ7sSYqB--
