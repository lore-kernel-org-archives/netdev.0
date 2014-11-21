From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] 8139too: Allow setting MTU larger than 1500
Date: Fri, 21 Nov 2014 18:51:51 +0000
Message-ID: <1416595911.7215.23.camel@decadent.org.uk>
References: <1415447316-12424-1-git-send-email-albeu@free.fr>
	 <1416530074.7215.11.camel@decadent.org.uk> <20141121145853.1be898de@tock>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Z6GLiCLOxGVy0PWC4A1f"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alban <albeu@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141121145853.1be898de@tock>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z6GLiCLOxGVy0PWC4A1f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 14:58 +0100, Alban wrote:
> On Fri, 21 Nov 2014 00:34:34 +0000
> Ben Hutchings <ben@decadent.org.uk> wrote:
>=20
> > On Sat, 2014-11-08 at 12:48 +0100, Alban Bedel wrote:
> > > Replace the default ndo_change_mtu callback with one that allow
> > > setting MTU that the driver can handle.
> > >=20
> > > Signed-off-by: Alban Bedel <albeu@free.fr>
> > > ---
> > >  drivers/net/ethernet/realtek/8139too.c | 13 ++++++++++++-
> > >  1 file changed, 12 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/realtek/8139too.c
> > > b/drivers/net/ethernet/realtek/8139too.c index 007b38c..8387de9
> > > 100644 --- a/drivers/net/ethernet/realtek/8139too.c
> > > +++ b/drivers/net/ethernet/realtek/8139too.c
> > > @@ -185,6 +185,9 @@ static int debug =3D -1;
> > >  /* max supported ethernet frame size -- must be at least
> > > (dev->mtu+14+4).*/ #define MAX_ETH_FRAME_SIZE	1536
> > > =20
> > > +/* max supported payload size */
> > > +#define MAX_ETH_DATA_SIZE	(MAX_ETH_FRAME_SIZE - ETH_HLEN -
> > > ETH_FCS_LEN)
> > [...]
> >=20
> > Does this maximum still allow for VLAN tags, or should it use
> > VLAN_ETH_HLEN instead of ETH_HLEN?
>=20
> That might well be as the VLAN code seems to assume that the physical
> device can handle frames of MTU + VLAN_HLEN bytes. I can fix it, but to
> me it seems like the VLAN code should be fixed to respect the physical
> device MTU.

Drivers that support VLANs have to allow for at least one VLAN tag when
validating the MTU.  This is obviously broken for multiple layers of
VLAN tags, but those are the semantics we're stuck with.

Ben.

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-Z6GLiCLOxGVy0PWC4A1f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVG+Jx+e/yOyVhhEJAQqU9A/9EhLgpP5fWbXomzhApckFCNnMkkpg007E
Sw9MwWTseFLXPSmatLD6Ceiz5CWj/BmvpFH7/zs9ibWxt5Ma0oTmXOp80V+ADdI6
Mj547YqeoEdReVo6bl2vQqpHxB8yQhkDJY8xiVdva1HrPk+iSmBBMdrxAgQoF0rZ
/gDqGHxidlSFrDVh/T9QZmsFd7o886/XdKEh/NlmtLPj38wQlGaajjNK8Q5SS0Ct
9Cs51H5f/t1yATCe7VlJJIYe8spnZlzzXeZuXeqxaTVG90VM4z4WEQjeNBp9TywS
lHJhm9LSq+nIYEMHCEi04L2rHqUlAqp3L1nLCCyWlPW36monXVLx160gSBjB9aZS
x+xbvAF33n3wXm25kYpq21zYJ0CY2eBuBzXYGWnuew8RnVw+sDbF0nAV/d4Hs6Or
c2Jk3eQfsS5d3aVIv6rqj8Lzpb645rR0Ouz77LewrCndBSwYJtseboE7zXPgnduT
OQ0huLNB84v71M11/bME99de05PYRhSB4ZrApswbjPMnd5wCEhuTUeifE//SMm5j
hVbCBUnl7711LGGUwFs/mdzslBwABmd7P7B3a2Z/EfqtpZv3o1G7Dab0UHJeTIb9
VqZCkMIU6+hAp90/y3maA6x62q8m5crouJ7I3RdwPEIK+E80GSkIWhrDPm5gsOtf
vuDtO03wxNQ=
=V4we
-----END PGP SIGNATURE-----

--=-Z6GLiCLOxGVy0PWC4A1f--
