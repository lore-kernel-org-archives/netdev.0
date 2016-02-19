From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Fri, 19 Feb 2016 00:06:27 +0000
Message-ID: <1455840387.2794.59.camel@decadent.org.uk>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	 <1455839111.2794.51.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B3871@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HlYuMMHGqF+dVzlAbRsd"
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55699 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1426944AbcBSAGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 19:06:35 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404B3871@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HlYuMMHGqF+dVzlAbRsd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-19 at 00:03 +0000, Woojung.Huh@microchip.com wrote:
> > > Add ethtool operations of set_pauseram and get_pauseparm.
> > [...]
> > > +static void lan78xx_get_pause(struct net_device *net,
> > > +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_pauseparam *pa=
use)
> > > +{
> > > +	struct lan78xx_net *dev =3D netdev_priv(net);
> > > +	struct phy_device *phydev =3D net->phydev;
> > > +	struct ethtool_cmd ecmd =3D { .cmd =3D ETHTOOL_GSET };
> > > +
> > > +	phy_ethtool_gset(phydev, &ecmd);
> > > +
> > > +	pause->autoneg =3D dev->fc_autoneg;
> > > +
> > > +	if (dev->fc_autoneg) {
> > > +		if (dev->fc_autoneg_control & FLOW_CTRL_TX)
> > > +			pause->tx_pause =3D 1;
> > > +
> > > +		if (dev->fc_autoneg_control & FLOW_CTRL_RX)
> > > +			pause->rx_pause =3D 1;
> >=20
> > This is incorrect; you should always return the manual settings
> > (fc_request_control flags) here. =C2=A0If autonegotiation is enabled th=
en
> > your get_settings function will return the actual pause flags.
> >=20
> > Ben.
>=20
> Ben, thanks for comments.
> How about comment in include/uapi/linux/ethtool.h?
> It says=C2=A0
> ** struct ethtool_pauseparam - Ethernet pause (flow control) parameters
> ...
> * If @autoneg is non-zero, the MAC is configured to send and/or
> * receive pause frames according to the result of autonegotiation.
>=20
> Doesn't this mean get_pauseparam() returns pause settings based on=C2=A0
> Result of autonegotation? Not manual settings of rx_param & tx_param?

No, get_pauseparam should return the same settings that were passed to
the last set_pauseparam.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-HlYuMMHGqF+dVzlAbRsd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsZcg+e/yOyVhhEJAQq5pA//YoaPJaWkXQJDg0snTCo7wTDIojxY1qAb
vgY6g8Xx0mHfUSm+Qu5aFhmemTKyJaKu0Xqs3FHxvzV8yN40tOJBpJIbEJGqJzMp
TZhbuFkTRcGyo/5/Qr91Vfx1gN8HSeACYHMArgG6Zb0Uf+L2Tn9zN719EviDgYow
JDXoB1E+ql0v8KJneMYOQey5aw5yrRVstSGIWz6naclMCIjsdkAfb/dJjA9g/5h7
EyRyvmzDe3f+zWefQfZ7O+3j+EK0mUatn1T+Dl9Hfi/Zk6of02VTF5Ko+uD+KyTf
XvxHHT8tLcBAJLyqJCJAmzFp6tuXIB6ouT/AKTYtYLYV4BAhTBx6KkNHYscIFiNB
9yODsYmZe1uMvp2vu2MXUWoThiAKmu/kMHmLo7OPWQqOvt4s6iNcSbBjinIKbat+
9QrS1GNSKvc4bRLsEqgOZLVmhs2orYBIWWaRU+dlXJK7BC0RZJCQZqFQdTNkvJfq
ch6k94mBhoxjLuECISvsv/bmMvPN1LubYTK9LILAnELMp1iNWHJuNaey/LC8daC1
EpoWDbU5iR49OQZGbrmN0g6/hwRrTUgpsBmfOQI6qIvACLBDPTEvMTQHE/AL71+g
MjlGy0IWWOZWpA3+F7JN5M7U1kRzRW43x5xPlZTSzlzEle/DDfvsn+YCTFjjqTII
IB0dVd7T98k=
=wczh
-----END PGP SIGNATURE-----

--=-HlYuMMHGqF+dVzlAbRsd--
