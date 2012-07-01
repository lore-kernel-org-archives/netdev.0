From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] e1000e: remove use of IP payload checksum
Date: Sat, 30 Jun 2012 22:32:39 -0700
Message-ID: <1341120759.2632.25.camel@jtkirshe-mobl>
References: <1341052528-2444-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1341092196.4852.43.camel@deadeye.wl.decadent.org.uk>
	 <20120630.173752.1993136000245136259.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0INls/016s/ieiYrNhcw"
Cc: ben@decadent.org.uk, bruce.w.allan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6426 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132Ab2GAFcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 01:32:52 -0400
In-Reply-To: <20120630.173752.1993136000245136259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0INls/016s/ieiYrNhcw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-06-30 at 17:37 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sat, 30 Jun 2012 22:36:36 +0100
>=20
> > On Sat, 2012-06-30 at 03:35 -0700, Jeff Kirsher wrote:
> >> From: Bruce Allan <bruce.w.allan@intel.com>
> >>=20
> >> Currently only used when packet split mode is enabled with jumbo frame=
s,
> >> IP payload checksum (for fragmented UDP packets) is mutually exclusive=
 with
> >> receive hashing offload since the hardware uses the same space in the
> >> receive descriptor for the hardware-provided packet checksum and the R=
SS
> >> hash, respectively.  Users currently must disable jumbos when receive
> >> hashing offload is enabled, or vice versa, because of this incompatibi=
lity.
> >> Since testing has shown that IP payload checksum does not provide any =
real
> >> benefit, just remove it so that there is no longer a choice between ju=
mbos
> >> or receive hashing offload but not both as done in other Intel GbE dri=
vers
> >> (e.g. e1000, igb).
> >>=20
> >> Also, add a missing check for IP checksum error reported by the hardwa=
re;
> >> let the stack verify the checksum when this happens.
> > [...]
> >=20
> > The change to enable RX hashing in 3.4, with this odd restriction seems
> > to have broken most existing systems using jumbo MTU on e1000e.  None o=
f
> > the distro scripts or network management daemons will automatically
> > change offload configuration before MTU; how could they know?
> >=20
> > Therefore this needs to be fixed in 3.5 and 3.4.y, not net-next.
>=20
> Agreed.

Ok, I will prepare it for net and stable 3.4.  I know it will require a
backported patch for stable 3.4.y since the current patch only applied
to net & net-next.

Bruce was wanting to have it applied to net & stable, and I was not sure
based on the patch content and description, so I that is why I submitted
it for net-next.

--=-0INls/016s/ieiYrNhcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP7+D3AAoJEOVv75VaS+3OOD0QAIJA1iTSlvuv3p88CEarsyeD
ceDAha6hJGcilhe3/98IC8XDD2FGJF+068UUoI4hB43Kc+T7JqoU5evKEnJwdIFN
qO5QzIugPvOR82xQ/NHhr2xvuxThimNeMcBHvy/NVWDiQBpGOMt/fBin7X/aZDoz
TkN4OEEv/lncA8ZDJoNiCaDM+mYLnjL8w13IouOgHNJmzCK70j65r8bPMGXQzvBi
fDTMPWGG9iS7JK6Z9nuM237BpmYszYAxYHNMjJ8o9kXuJkX+BjicG/KU0VXw2ZbW
nPdK+9PXfA5iVJl1otvmqiZVzelVurUgz+PVFnefSpSnzU+emfePzhdV59P4U/fm
4Wx7i9PMrdtptGUz8kI5JXnHS+xT2aMibXyCXb+YaDSMtNIGNzl7BLmMal31yIVb
pgEeAg5Imt/72LG7u6xNJoodH8XBXKxDu3FVPRaqOV01lKd6vDkEROUGi5GK2rNv
i23Sk2aJy5tJpJvcHRAG7xxj8w/3wmLX5TTpORIl46RtDZ5u3PB/D2f+cgu/PGd/
EKi6o68mmy0VxCnSFQBzOz1A3Xnw5q3rZVRsLBAC4FZQ9ks7mOjmVyYHQuJgqeSu
bZiAFoUX++VALevayIT+21nZeFmsKvMUzpT69yuOtE2oL84yue5Xl5wH52Q5gvE/
EanXOJ+N4Oj7LUyDopER
=UlfF
-----END PGP SIGNATURE-----

--=-0INls/016s/ieiYrNhcw--
