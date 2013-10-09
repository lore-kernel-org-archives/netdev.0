From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed, 9 Oct 2013 19:05:57 +0200
Message-ID: <20131009170557.GK3544@neomailbox.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
 <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
 <20131009143500.GH3544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7385@saturn3.aculab.com>
 <20131009161028.GI3544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7386@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="81JctsDUVPekGcy+"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12695 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab3JIRGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:06:24 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7386@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--81JctsDUVPekGcy+
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 09, 2013 at 05:19:44PM +0100, David Laight wrote:
> > On Wed, Oct 09, 2013 at 04:49:53PM +0100, David Laight wrote:
> > > > > Are you really generating CRC32 of a pile of ethernet MAC address=
es
> > > > > and the XORing the CRC together?
> > > > > That gives the same answer as XORing together the MAC addresses a=
nd
> > > > > then doing a CRC of the final value.
> > > >
> > > > I was not sure about this since the CRC32 is not a linear operation=
=2E However
> > > > this routine is not on the fast path, so we can also live with this=
 order.
> > >
> > > All CRC are linear.
> > > Because '(a + b) mod c' is the same as '((a mod c) + (b mod c)) mod c=
'.
> > >
> > > The CRC of a buffer is the XOR of the CRCs generated for each '1' bit.
> > > The CRC for each bit depends on how far it is from the end of the buf=
fer.
> >=20
> > In our tables we cannot make any assumption about the order of the entr=
ies: the
> > node whom generated the table may store the entries in a different orde=
r from
> > what we have got.
> > This is why I did not implemented it as a simple CRC of the
> > whole the GlobalTable/buffer but I CRC'd each MAC+VID on its own.
> >=20
> ...
> >=20
> > Assuming what I said above (that we cannot make assumptions on the orde=
r of the
> > entries), what is your suggestion?
>=20
> I'm not sure what you are using this CRC for.
> If you are trying to use it to check that the two tables match - so a
> full update isn't needed then it just won't work.

No, we have a sequence number for this purpose.

The CRC is only used to check that (after having applied all the needed cha=
nges)
the content of the table is really the same as the one owned by whom genera=
ted
it.

Therefore the CRC is practically used only to check that the node memory ha=
s not
been corrupted and I can hardly imagine that such a case can lead to the sa=
me
CRC as the expected one (of course, probability is not zero, but that's bec=
ause
it is an hash function..).

The conclusion is that we can live with this patch :-)

Thank you anyway for your explanation. This will surely help in case we dec=
ide
to change/improve it.


Regards,

--=20
Antonio Quartulli

--81JctsDUVPekGcy+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSVYz1AAoJEADl0hg6qKeOHuMQAIs2yoqJEwL3522qPs1LbgXu
mDD7MDc0nqW0Wx0nc9lYTdBnyIVVSy4PjO8oSAvSWNTqTrCbQmn5KDVfooBa/HCZ
/lbFGgCrkr5A/oFBvyxvzbbft10/Tdr1vZx615KQ9sFDL8h1fUoMSZiw1sK6GddI
VxjOzAei34fAGMXdNnQRVen54Uba3fWQ7Omk702X5uYAiP3DDIcqeYhA3/IewK6P
iUD5YeJYpvCx6TizpkeTn+OYUTw+H6nn406NzTff4+/0+j6W/nDxNkbi4aK54UY6
o2+UhJqg+EzkVZl7MO5tQhZG0mZaGbJmQzl2Gqhd35xDxhzdtLLdXhYtNs9bYjJD
sFm+QGKjzlFcv9NGgIT64UcAbvn2cYL68+V737TzMFncapMDp+VEd7TEXubIO+ZP
6/5mxAK7sFnp9EXwtsvr4Ya9IW3apufamv9GAzhWnkKXPW1XRAmlR9gPpbNXaGip
BpRi5wKumC6/O9m5mfFKnzViDUJoqJvSXfIpznSQ8LwaoOCq89UQRg4zyyyVuiM2
PYlGNvkL9D2KMeF9wlUDSOmNhomQKZ+5Ai4IAt56yNIThiMmbkq3Xv+r/FiikT6m
f3ErmnW1aIlKsw0H1hDEGKI5Zk8s+SiTUgf9ixaIWZ34b6B4TjvqKx6tmG999z07
1lyKa3Kwe5pBSyZW6ujq
=5ymY
-----END PGP SIGNATURE-----

--81JctsDUVPekGcy+--
