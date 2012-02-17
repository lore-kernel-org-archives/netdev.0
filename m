From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: tg3: Use *_UNKNOWN ethtool definitions
Date: Fri, 17 Feb 2012 09:48:30 +0300
Message-ID: <20120217064830.GA14483@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:45005 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab2BQGq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 01:46:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Matt Carlson,

The patch e740522e6d3a: "tg3: Use *_UNKNOWN ethtool definitions" from=20
Feb 13, 2012, leads to the following Smatch warning:
drivers/net/ethernet/broadcom/tg3.c:1822 tg3_adjust_link()
	 error: tp->link_config.active_speed is never equal to -1 (wrong type 0 - =
65535).

-       if ((phydev->link && tp->link_config.active_speed =3D=3D SPEED_INVA=
LID) ||
-           (!phydev->link && tp->link_config.active_speed !=3D SPEED_INVAL=
ID) ||
+       if ((phydev->link && tp->link_config.active_speed =3D=3D SPEED_UNKN=
OWN) ||
+           (!phydev->link && tp->link_config.active_speed !=3D SPEED_UNKNO=
WN) ||

Since tp->link_config.active_speed is an unsigned short, it never is
equal to SPEED_UNKNOWN (-1).

I introduced the SPEED_UNKNOWN so I feel bad that it's causing trouble
now.  :/

Also this warning:
drivers/net/ethernet/broadcom/tg3.c:3909 tg3_phy_copper_begin(14)
error: tp->link_config.speed is never equal to -1 (wrong type 0 - 65535).

regards,
dan carpenter



--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPPfg9AAoJEOnZkXI/YHqRT6sP/3aX38rNYYBHmDYhNGMmQpRz
UlqUh7KKNyaOAzHVbHCM6A21S/khbfeb4L+7OCybql7GuDU/gp4lLpWe+0e3MfNW
fOvuMoj3SPCCfo3tDMZWBnHqxf+svdpw67DeyqQquxjEntRWK5RQ275/Vmer698c
YwUBq0Cs3juLYNfSCJFTkbBayBhk8dqnK1dFvrC+bLVhY8GQUZc/ksX0RQb29s3g
+G/Kyjn7saPn+uJRvaj0duREbzPCsXFGfNkFmAE+zgkXAaYxg4RhBEJEj5+0Eozg
eeQGxbEmV7f093gIpU636wUQTn16pMDtsYqK8kXFj0o9TKZ6AYgQxTKo9OvsK6oH
1LwmYaSqwvGG4xZNv7OKjn+C5PDhHnsCHFiET9Bgyu5tiURyab0/5qxqnaPABe/I
2cVHe6Vtsl4ZjCul4uBo05RylwOS1wD967I7sjeKDbxT7ky4D//kwXyonTPwjnZk
XmXmNcbLWqIftiXl8THYD5juBQkuLnfhZpHmTBGSDKL+yxQTOWx0AaizI+mgkutD
3wJjTgvIbKwF8AwfFaFGvRSpbozkNbAe42oXy470jmvQPylJvrAUVUzvIUZ/Blh6
i6cYVlfn584dwEtQTysJC4VaTFUoumemYJnmBYupA2hhizWlGAJ7gV91os3JU24K
VnnA5xWUUAEZ3Mo9C7h7
=aSDE
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
