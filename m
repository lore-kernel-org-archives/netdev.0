From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX II
 rev < 12
Date: Tue, 23 Oct 2012 02:45:07 +0100
Message-ID: <1350956707.5283.48.camel@deadeye.wl.decadent.org.uk>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
	 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
	 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
	 <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
	 <1350675530.8764.131.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAG2Wgfdn52R2FYh77-2ZHCFVwe8d0MOv_4but6aOsU50jF-+Lg@mail.gmail.com>
	 <1350946459.8764.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-El7Myf1JieOVweuwy9mz"
Cc: Teodor MICU <mteodor@gmail.com>, netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>, 690845@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42283 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756450Ab2JWBpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 21:45:19 -0400
In-Reply-To: <1350946459.8764.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-El7Myf1JieOVweuwy9mz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-10-22 at 15:54 -0700, Michael Chan wrote:
> On Mon, 2012-10-22 at 10:52 +0300, Teodor MICU wrote:
> > 08:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
> > Gigabit Ethernet (rev 11)
>=20
> It is 5708 B1, and due to some hardware limitations, ethtool initiated
> WoL is not supported.
[...]

Well we knew that much!  Is the problem that the system firmware 'owns'
the WoL control registers so the host can't safely change them?  Is it
possible to *read* the WoL configuration, if not to change it?

(If even that is not possible, the correct thing to do might be for
ETHTOOL_GWOL to return 'don't know' (EOPNOTSUPP) for this device.  But
since ethtool_ops::get_wol (and various other operations) can't return
an error, that would require you to define a separate instance of
ethtool_ops with get_wol =3D NULL.  I should look at fixing that...)

Ben.

--=20
Ben Hutchings
Humour is the best antidote to reality.

--=-El7Myf1JieOVweuwy9mz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUIX2o+e/yOyVhhEJAQpOFA/+NJ08SL9gSLRf8e2YrMHW+g0kXjIGjBqp
8C50ylQcki+Bb+86Ifj+zsCoog/oS9nZ3X5aksbiwN6egNgN4FIHX70L1ZJhH2AJ
lL5Nz5g9D2ksqV6VOEHkhy3BgawnuUBHn6+Vg/PwBk8YDX12Vnvfw0gmGz6+e6dd
gut2pqFgI8rwsRHNekzo+lsNFf1VE0/dc6VinEoXpm0D6oQ35/UEgl9eqEgTKJnb
ux1SCOael/NPWzeBD9unfTIHvEETQdVf/O0+olS+X0yCvV8OzoIZGgD/e7RsCkux
osD5CewDWw35XxyHxKHB3oC1rXSufh7AYwXnilelebQP0I6DPzPVx4x80iAJReGd
Nu/x5Ri7XkLWN8goxFxirTiJ/4ritwgQmHrjwAk2UgIF9L1LBjigNFcoCGD6DheO
P1hY2lqTWHfZ/I9KxvuEgNVEbL2K5xumgDTEgyDk5E36u3BxNx7f5VHruV8V7P5b
bOWlGH0yn6LirZiXqVnUoJVyy0rwUny2kcUOL69TJ2LNbFFFUs+0cyjLiKoTpO1H
kiX4WPOl9Qfk3vsysKaWzxL2HqRrCxFnWDotglDDt3hQIE/Le481xyNwKb+uzV6Y
bvh/XMFE1dNOGsbaeE8FtQnSfHqI30GK4ex3wxRBLhRkGEihHZIfMaKJkZEO61Tp
cbwBtXJxWjg=
=klk3
-----END PGP SIGNATURE-----

--=-El7Myf1JieOVweuwy9mz--
