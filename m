From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Wed, 5 Jun 2013 10:41:11 +0100
Message-ID: <20130605094111.GB2522@raven>
References: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
 <1370245762-5126-2-git-send-email-tparkin@katalix.com>
 <1370270652.1918.14.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KFztAG8eRSV9hGtP"
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41272 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387Ab3FEJlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 05:41:14 -0400
Content-Disposition: inline
In-Reply-To: <1370270652.1918.14.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 03, 2013 at 03:44:12PM +0100, Ben Hutchings wrote:
> On Mon, 2013-06-03 at 08:49 +0100, Tom Parkin wrote:
> > Hardware offload for UDP datagram checksum calculation doesn't work with
> > fragmented IP packets -- the device will note the fragmentation and lea=
ve the
> > UDP checksum well alone.
> >=20
> > As such, if we expect the L2TP packet to be fragmented by the IP layer =
we need
> > to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).
> >
> > This change modifies the L2TP xmit path to fallback to software checksum
> > calculation if the L2TP packet + IP header exceeds the tunnel device MT=
U.
> [...]
>=20
> Surely this should be done in the IP stack when fragmenting, not in any
> particular client?
>=20

Hmm, that's a good question.

I'm not sure it makes sense to push this down into the IP layer, though.  S=
ince=20
it's the UDP checksum we're calculating, it seems reasonable to handle it a=
t=20
the UDP layer (which is where L2TP sits when using UDP encapsulation).

If you're worried about reproducing similar code in both UDP and L2TP
I can see where you're coming from, but since UDP uses corking and
L2TP doesn't the data transmit path is quite dissimilar.  We could
probably do some work to share the code, but it doesn't seem worth it
for the amount of sharing we'd be able to achieve.
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--KFztAG8eRSV9hGtP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRrwe3AAoJEJSMBmUKuovQBr0H/AmjAPg2dTSuWY6Qi9QtuSTz
O2L3I7yPoF+ZHi1vgCtPiJ1TYaWF7b3bVFQT5akqvsHFVlmBdTkLvCIY1DgPCu3i
OK21oweapG2ja52+itZbMRAevu/fEyZoaGXpfFtlW7JgN3Ofg4vNuM7ONpIulNQI
ALegVUhFp4geZtq7GyDVEp/PYbtso5mrsNWg/VNMmKrPFq9Nk7PFzl4ZWL6QoIky
Zp984dOtxGSBXDQFPaMf4KY5qdvrZNTnhOYZ3ZWHPbd0HDWcdPeTtE5QCRdQwpH4
8yAm5ZduCLO81hawtWWvpQzRuzV8I7+kMmB+u71kwcwjoJIDyS95vsjv6TOKbNc=
=wuvG
-----END PGP SIGNATURE-----

--KFztAG8eRSV9hGtP--
