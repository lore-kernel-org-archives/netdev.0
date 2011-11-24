From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] isdn: avoid copying too long drvid
Date: Thu, 24 Nov 2011 15:42:09 +0300
Message-ID: <20111124124209.GI3195@mwanda>
References: <20111123064345.GB6871@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ijf6z65S790CMqo8"
Cc: "David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:38052 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab1KXMmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:42:23 -0500
Content-Disposition: inline
In-Reply-To: <20111123064345.GB6871@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ijf6z65S790CMqo8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

"cfg->drvid" comes from the user so there is a possibility they
didn't NUL terminate it properly.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: use strnlen() instead of strlen().

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 1f73d7f..2339d73 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2756,6 +2756,9 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg)
 			char *c,
 			*e;
=20
+			if (strnlen(cfg->drvid, sizeof(cfg->drvid)) =3D=3D
+					sizeof(cfg->drvid))
+				return -EINVAL;
 			drvidx =3D -1;
 			chidx =3D -1;
 			strcpy(drvid, cfg->drvid);

--ijf6z65S790CMqo8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOzjugAAoJEOnZkXI/YHqRjeUP/AnvYbN+KlkcVRTMi5K6SAPX
3EObvfrczzX6QQTyq0KvC1+f/ZMj6SB5VGyOYDKPgP24xBKn4mWfvt0uDG350dd9
ZXjEEpMByz3iqGYrx2zeVfF8JTFnLJVSj/n4oCGDKb16w8Gf+UPeeEFxFHu8Z4wd
YE1lR0pbuAoPzo9Q0r+f/3D5Pps4O4roRPfmBUTEJK75OCh9JgHKFPSVZR5fpM43
zL42JcDoBhGl2YK695iie4eWPe2zVEGIY4L55PuTpWPmh3ywrojJtVtxSQwrw4XO
SBtTbjdFSivEkYYcgiDo7+CmzFjpRKoLLWW+CO8B+xleeSt/qTvgAaczKwTcY32V
Jl1F5wlE3fHVyCd3hRgeRa1zGKDgKnBJwzjj/uxCahZVv4qzFkVdgmXtglu7OsSF
oEGizytwfba+l41X7ZdratpLaWavFy3MJZhqRbMMjOckQfqOdAyD9YOICdNYLUZt
4uXSPIDzBOE95DxPxsXt4EIwjlkrac2RR9gXU2aXNf3W+8O33QEMmUcnNjWRpZDy
NU5oCPDYLeeUwfoWYzHSsqx3mVZWjm0OxqoOrh1v/qgJA4bw3RPrEsglzQU5jSh5
Ts/ZosdOHbeOvggYBjmsoWwLonHIJrVoty+qcuUK4RqZKCXaWXzznKTNZrM65RJt
SYLm2/uTZgxGjHo21kmV
=rVVV
-----END PGP SIGNATURE-----

--ijf6z65S790CMqo8--
