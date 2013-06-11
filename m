From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Tue, 11 Jun 2013 09:00:38 +0100
Message-ID: <20130611080038.GA2496@raven>
References: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
 <1370245762-5126-2-git-send-email-tparkin@katalix.com>
 <1370270652.1918.14.camel@bwh-desktop.uk.level5networks.com>
 <20130605094111.GB2522@raven>
 <1370437077.4021.15.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41562 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab3FKIAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 04:00:42 -0400
Content-Disposition: inline
In-Reply-To: <1370437077.4021.15.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 05, 2013 at 01:57:57PM +0100, Ben Hutchings wrote:
> On Wed, 2013-06-05 at 10:41 +0100, Tom Parkin wrote:
> > On Mon, Jun 03, 2013 at 03:44:12PM +0100, Ben Hutchings wrote:
> > > On Mon, 2013-06-03 at 08:49 +0100, Tom Parkin wrote:
> > > > Hardware offload for UDP datagram checksum calculation doesn't work=
 with
> > > > fragmented IP packets -- the device will note the fragmentation and=
 leave the
> > > > UDP checksum well alone.
> > > >=20
> > > > As such, if we expect the L2TP packet to be fragmented by the IP la=
yer we need
> > > > to perform the UDP checksum ourselves in software (ref: net/ipv4/ud=
p.c).
> > > >
> > > > This change modifies the L2TP xmit path to fallback to software che=
cksum
> > > > calculation if the L2TP packet + IP header exceeds the tunnel devic=
e MTU.
> > > [...]
> > >=20
> > > Surely this should be done in the IP stack when fragmenting, not in a=
ny
> > > particular client?
> > >=20
> >=20
> > Hmm, that's a good question.
> >=20
> > I'm not sure it makes sense to push this down into the IP layer, though=
=2E  Since=20
> > it's the UDP checksum we're calculating, it seems reasonable to handle =
it at=20
> > the UDP layer (which is where L2TP sits when using UDP encapsulation).
>=20
> TCP, UDP and similar checksums can be handled generically, e.g. if
> dev_hard_start_xmit() finds the device doesn't actually do checksum
> offload then it calls skb_checksum_help() to fill it in.  I was thinking
> that since the IP layer makes the decision to fragment then it should
> also be responsible for filling in the checksum before doing so.  Why
> should the transport layer protocol have to guess?

Fair point!

I suppose an argument can be made either way, so really it comes down to a
question of taste and a feel for how the net tree "should" handle
this.

Dave -- could you give me a steer?  Are you happy to keep this kind of
calculation in the transport layer, or should I look to push something
generic into the IP code?

Thanks,
Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRttkmAAoJEJSMBmUKuovQLzQH/23mdsaF1qyUF2n/WA+2W0rE
uFBQ4ip4TLcBkV/9KbBPa/ot8t03MUCU9OuzFlvDiDFA0aMuRGHGO3NJ7HtJNpmA
Sxn9GWe0YlpX2S2EwEsrVoEhpDUnK1GKjSVDmdYCTiwC0k6n4nIPsh23XFv44deH
HpbHN5AxcMeREETpw/JyEpQFI381hR9MWgGpKuwSC0Bru+p8/OTVOUz4EnHpPsRz
y7k9LqSG0G6FRWFAnCu1lcro+58CeqMJ9dPDZUYPmmlDYxk2s9Q3bcXSeFqr/s7B
Z8CHj08/JA851dp0EMknVw+MXnnWza5AJybu0KbjBNwDAv9cXgeNDefh/YlsgUw=
=WhnR
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
