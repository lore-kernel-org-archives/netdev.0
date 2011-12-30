From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [BUG] SIOCSIFFLAGS returns -EIO on SMSC LAN911x
Date: Fri, 30 Dec 2011 14:15:48 +0100
Message-ID: <1325250948.13595.100.camel@deadeye>
References: <CAAwP0s37E=9J-KR397snkvq=idrc7nmELDJKrm33reeK84wJYQ@mail.gmail.com>
	 <1325242573.13595.71.camel@deadeye>
	 <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5Tdg7QplIjqbzmkLLIpx"
Cc: netdev@vger.kernel.org,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49057 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752902Ab1L3NP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 08:15:56 -0500
In-Reply-To: <CAAwP0s0Y329AAXpHW9muOECt5DpgpDm6kefXR7uE1233A1LGWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5Tdg7QplIjqbzmkLLIpx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-12-30 at 13:58 +0100, Javier Martinez Canillas wrote:
> On Fri, Dec 30, 2011 at 11:56 AM, Ben Hutchings <ben@decadent.org.uk> wro=
te:
> > On Fri, 2011-12-30 at 10:44 +0100, Javier Martinez Canillas wrote:
[...]
> >> Did anyone have the same problem?
> >>
> >> The problem is really strange to me, especially since we are sure that
> >> all the requirements to software reset the device are meet in both
> >> cases (with SMSC_PHY compiled built-in and without it)
> >
> > I don't know about that.  smsc_phy_config_init() attempts to enable
> > power-saving on the PHY, but it is writing to a bit that is reserved
> > according to the data sheet for the combined MAC/PHY chip.  dwein
>=20
> Since the PHY chip is a lan8700, the power-saving seems to be correct.

But the feature may not be supported in the combined chip, the 9221i.  I
would tend to believe the more specific data sheet.

> But the problem is when latter in the open handler a software reset is
> attempt.
>=20
> Probably I can protect the software reset and only try to reset the
> device if the PHY is now in a low power mode. But if we don't reset
> the device at interface bringing up, when should we do a the reset?

You may have to change the order of initialisation of the PHY and MAC so
that reset works properly.

> I'm not that familiarized with the networking layer, if someone can
> give me some light I can fix the issue and send a patch.

This really doesn't have much to do with general networking, only phylib
and the specifics of the SMSC hardware and drivers.  The smsc911x driver
is responsible for calling phylib functions and so the hardware
initialisation is very much under its control.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-5Tdg7QplIjqbzmkLLIpx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATv25hOe/yOyVhhEJAQpvrw/8DBTU0gKSsRJg6oLSR29D/34C1L2MBvS0
HbkSCiL9F8hZkg0Oi9IXwtN0yGY3AfeEGz3OZ471qzZxcAbzR5FOr8gz472YL6OC
XeOsuQd+X6mRvajHG60PR767YFsfqJHljV3wzHoKlnj+vtyF2SltUuh4vy7o2saO
rWYHB/Y/NWI8p35FST1/oKFa/bK9f+34ghXxszYoMZFsF59XJPou7xW7Aj68hs5z
z914Sw/mQKx0WfBD5PbclafxetzCTgnBnlqWUJTAS5kVjLy9BSBOYncqjfqEnI5+
mG61lD3pG+JtVb8Fyx9J/m2M+KTwgT6aSwkZwTSQNjloZItPhbApgTocgwepTjr2
OQdR37+CHzTg9XNNpkZHfaU437wsJmRhqZOuB9MWMENjdbk1CD/Z9+UvTNB5LgCt
RAIuszHxI6zEw6SrVOy2f3sXkAvMAov7YIl1EZqcF58KYYMPJnr63jR1yZQJ2rvc
MbqWdMfCiLGzKe7lhtxaULsgANsLfQbPe9A+u/etYIQD3poPIR44dxkreRUe2WFD
GldLeOqeBtv1DuOpzVNchdUob8E/BLnNH2bl+vhI3LdGVodc9iinYKkHxc4Tx6DG
BtavoVtXgfnmkglZFJ43rYMsIf1L9G0zAqHsT2RVtoi/ooXZhsl1q8Kau7pPK5Py
UG7c0pZCaVc=
=k9WM
-----END PGP SIGNATURE-----

--=-5Tdg7QplIjqbzmkLLIpx--
