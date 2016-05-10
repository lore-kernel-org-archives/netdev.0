From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for
 get_coalesce, set_coalesce ethtool operations
Date: Tue, 10 May 2016 13:02:35 +0100
Message-ID: <1462881755.2626.12.camel@decadent.org.uk>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>
	 <1462576336-83513-6-git-send-email-skhare@vmware.com>
	 <1462622686.19332.33.camel@decadent.org.uk>
	 <alpine.DEB.2.10.1605081335140.13942@shri-linux.eng.vmware.com>
	 <1462753040.9308.11.camel@decadent.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D5F4B8B61@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iiMQqV8UzwYRI97f7tEu"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Keyong Sun <sunk@vmware.com>,
	Manoj Tammali <tammalim@vmware.com>
To: David Laight <David.Laight@ACULAB.COM>,
	Shrikrishna Khare <skhare@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4B8B61@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iiMQqV8UzwYRI97f7tEu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-10 at 11:24 +0000, David Laight wrote:
> From: Ben Hutchings
> >=20
> > Sent: 09 May 2016 01:17
> > On Sun, 2016-05-08 at 13:55 -0700, Shrikrishna Khare wrote:
> > >=20
> > >=20
> > > On Sat, 7 May 2016, Ben Hutchings wrote:
> > >=20
> > > >=20
> > > > On Fri, 2016-05-06 at 16:12 -0700, Shrikrishna Khare wrote:
> > > > [...]
> > > > >=20
> > > > > +static int
> > > > > +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_c=
oalesce *ec)
> > > > > +{
> > > > [...]
> > > > >=20
> > > > > +=C2=A0=C2=A0=C2=A0switch (ec->rx_coalesce_usecs) {
> > > > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_DEFAULT:
> > > > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_DISABLED:
> > > > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_ADAPT:
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0if (ec->tx_max_coalesced_frames ||
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0ec->tx_max_coalesced_frames_irq ||
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0ec->rx_max_coalesced_frames_irq) {
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return -EINVAL;
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0}
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0adapter->coal_conf->coalMode =3D ec->rx_coalesce_usecs;
> > > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0break;
> > > > > +=C2=A0=C2=A0=C2=A0case VMXNET3_COALESCE_STATIC:
> > > > [...]
> > > >=20
> > > > I don't want to see drivers introducing magic values for fields tha=
t
> > > > are denominated in microseconds (especially not for 0, which is the
> > > > correct way to specify 'no coalescing'). =C2=A0If the current
> > > > ethtool_coalesce structure is inadequate, propose an extension.
> > > For vmxnet3, we need an ethtool mechanism to indicate coalescing mode=
 to
> > > the device.
> > >=20
> > > Would a patch that maps 0 to 'no coalescing' be acceptable? That is:
> > >=20
> > > rx-usecs =3D 0 -> coalescing disabled.
> > > rx-usecs =3D 1 -> default (chosen by the device).
> > > rx-usecs =3D 2 -> adaptive coalescing.
> > > rx-usecs =3D 3 -> static coalescing.
> Would it be better to use stupidly large values for the non-zero special =
values?
> That would less problematic if someone expects 2 to mean '2 usecs'.

That seems less problematic, but I think we'd have to check that
current drivers (or at least the most widely used ones) reject those
values.

We should still need to standardise names and definitions for those
special values, so that the ethtool utility can provide keywords and
documentation for them.

Ben.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.
--=-iiMQqV8UzwYRI97f7tEu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXMc3bAAoJEOe/yOyVhhEJGCIQAJgFuA+gzyq98HArz/+IXF1v
uMq87lwUPexZdMIb9Hu5FQ8BEjRjF3CERHcF3VU1MY5U7mdr6gdU5SWC3tyib4ck
UBuEBo+iNQj5MutWQ6bfR7/TG/hxfjHKw0rKtMJbMf2Qm4Bjjonc3FrDkdeYqmRb
EUOi/UvUjcE9u+uwDuln3K5y8gf6VZ4Ebtp3imfV1JCKbT3Gpliu2lpJf8dCodMK
1G4eZz/wNGDROnizhQPRONroQQkzUUrWEv6AOCocPKMQSAu7tbFNGBphEpvP/Yqi
YPufXymP6eg2SHs4FuXodiQOej4Doc9hINGsuZBAMTrl0Ir+pMt7EkIxcqb0u84K
/0NirYcxKPv6QqhV6+3dS/WhO87JauomIjeQxdYhIEeDCODvdSfyoAD6kE5uW0r5
2Y3mxhKiLYLVbnjtyVWcZzzH8P01Z5oCvg0vOeMfVyxlwEEQjyiH0lOIRu6F78/k
fgpdkGSruQjZxsDlYWG/f8I2umY1Xm6g7pitNEcwXyzjdbloTu+U5d7t8WJAnl0+
a1HWRaFu/wHryueN6rqtJe5UeC2DNl+XoXG+UmRXtO5nowOTNZBEEecBP0bRDoW2
UYs8hmnA1vK4v5jW7SUwb3Uq9twBuP52IhvVRfoiJmrMHlkVfOR/VXvDsAujNVQG
tbB25xSGRUtaRQiVOUvw
=EruA
-----END PGP SIGNATURE-----

--=-iiMQqV8UzwYRI97f7tEu--
