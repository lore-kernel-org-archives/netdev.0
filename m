From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 08 Dec 2015 19:45:44 +0000
Message-ID: <1449603944.2824.103.camel@decadent.org.uk>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
	 <CAP-MU4OHMz8DaMwvF7=0ZgMCFdW0_85KH5O5ke55-X6Ox1Vw2Q@mail.gmail.com>
	 <1449601252.2824.101.camel@decadent.org.uk>
	 <37D7C6CF3E00A74B8858931C1DB2F077019AA989@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-z2W1luaKwJG/bRHL75pJ"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org
To: "Liang, Kan" <kan.liang@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55485 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbbLHTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 14:45:57 -0500
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F077019AA989@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-z2W1luaKwJG/bRHL75pJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-12-08 at 19:43 +0000, Liang, Kan wrote:
>=20
> >=20
> > On Tue, 2015-12-08 at 10:02 -0800, Shannon Nelson wrote:
> > > On Mon, Dec 7, 2015 at 8:42 PM,=C2=A0=C2=A0<kan.liang@intel.com> wrot=
e:
> > > > From: Kan Liang <kan.liang@intel.com>
> > > >=20
> > > > Intrdouce "queue" option for coalesce getting and setting.
> > [...]
> > > > --- a/net/core/ethtool.c
> > > > +++ b/net/core/ethtool.c
> > > > @@ -1123,10 +1123,16 @@ static noinline_for_stack int
> > > > ethtool_get_coalesce(struct net_device *dev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0void __user
> > > > *useraddr)
> > > > =C2=A0{
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_coal=
esce coalesce =3D { .cmd =3D
> > > > ETHTOOL_GCOALESCE };
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_coalesce =
tmp =3D { .queue =3D -1 };
> > > >=20
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!dev->ethtool_o=
ps->get_coalesce)
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return -EOPNOTSUPP;
> > > >=20
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (copy_from_user(&tmp,=
 useraddr, sizeof(coalesce)))
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0return -EFAULT;
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0coalesce.queue =3D tmp.q=
ueue;
> > > > +
> > >=20
> > > Is this going to do what you expect when you have an older ethtool
> > > program?=C2=A0=C2=A0It seems to me that the older ethtool program wil=
l have the
> > > original coalesce struct without the new queue field, so when you do
> > [...]
> >=20
> > Indeed, it's not safe to extend UAPI structures like this.
>=20
> Any suggestions for that?
> If we cannot extend the existing UAPI structures. I guess we have to add
> a new Ioctl like ETHTOOL_GCOALESCE_V2 for the new structure?

Something like that.

While you're at it, add a flags field which will indicate which of the
others are supported. =C2=A0Also, there was some talk of adding settings fo=
r
RX DMA coalescing.

Ben.

--=20
Ben Hutchings
Life would be so much easier if we could look at the source code.
--=-z2W1luaKwJG/bRHL75pJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVmczaOe/yOyVhhEJAQqIXxAAylcElYAkH8FcrZWpBxTcpiaFxk+Lma9s
TNWrFNgB6F4EOn07vRhDscc6O2+jMLrNKmeLZrfJ9AeidME0rACde5G7+JskaOEq
YCtrm6UneJjSMRlAbAnGdqVBd8GNPvqPViiRS7jxx62FBzvKVICAfHJZHNRH07ic
DTDV+kWqGFHVtdMujtLlSnhUERWVmC6npzK7GZAdYdRc9npYjtiJTe5/axwVL08R
faHYJFgFYgymwYDHcGni8aJiFeyH228+aIzR3pmSJld1TUk1kY0oqIOLx+aKc8QJ
4NdwzaL84IFWJp9AaY+oyosUU74HDKetw18B880NjAvZA0aLHGK7PGCejsT/jfv7
Uwmua0Ont402ir60+j9GeCJpCoFmPmOuV1Vk+w5yEzYa+FttkgN7y1JTZQI7KKQc
BIiaaPldEV18XxlJCl1WT6F91k8itSNyKHiufsz9j6Z6WrkPazlyIcUMNNchp7+E
xBrU9hfI6uInJ3+XMpYcGUkaT6bWZQV81YBVSxizIXcqQZk5h07Bba335r6MkOdY
uJMLIIf603l+GB58lYepF0FwxQ2NoLjlolrz2esUqmw/zac72/fUs3Iq+SJMu+sE
1vG0WIqeuzZ4WuKSAu2kTceo9LVX9FfOd15CxsiDK6MpH7YgzSq1SnUYyu9zCqB3
KklFmTZrIII=
=cApu
-----END PGP SIGNATURE-----

--=-z2W1luaKwJG/bRHL75pJ--
