From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool] Fix formatting of RX flow hash indirection table
 when size % 8 != 0
Date: Sun, 05 Apr 2015 03:14:59 +0100
Message-ID: <1428200099.11260.140.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-5-git-send-email-amirv@mellanox.com>
	 <1428199259.11260.137.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pa124ZuN84ifUWHP9URQ"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58748 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbbDECPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 22:15:11 -0400
In-Reply-To: <1428199259.11260.137.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pa124ZuN84ifUWHP9URQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We only print a new-line after every 8 entries, but we need one
at the end of the table even if the table size is not a multiple
of 8.

Reported-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is what I've applied - hope it works for you as I don't have a test
case.

Ben.

 ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index bf583f3..996efb9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3126,7 +3126,7 @@ static void print_indir_table(struct cmd_context *ctx=
,
 		if (i % 8 =3D=3D 0)
 			printf("%5u: ", i);
 		printf(" %5u", indir[i]);
-		if (i % 8 =3D=3D 7)
+		if (i % 8 =3D=3D 7 || i =3D=3D indir_size - 1)
 			fputc('\n', stdout);
 	}
 }


--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-pa124ZuN84ifUWHP9URQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCaqOe/yOyVhhEJAQqgFBAAkL6qxmrZKskuJ/tl8io8kckBpoyxgnfy
1cd6qP/C1B4FAwBjUXs7C9QdfPOc/hEiXpysQIa7OTgwNN891DGfn7V34iYbMC5+
1/2ZxB/rwn5HhfIbOwiTjrFZaoi1th50EnKGRaJMxffEDPmTHYCitF8X3wEJnH26
Y+ARGkQcvDYT3uqUHXY2SgmdUL8URQ7chbuIxXiIUf5LRg8evIDSslXqrFHeGcPW
kFfvGkjpITGAN/yoHEmfNLjC9cqbyEgw/5p8XIFtRt907+lGhqAObQhSuUY/CbP+
vFxl2Go2lcEhfOlQVuE4MH9b+q1iXm6DLtMdPMEjU0ZG/zcvSr2ffwwe93wY70n8
SN1CLUsTS62gZqHiB7NKs9tTg1yauXBNOWN/how4ldfaTqP5nU/WswdXmp+rOAdH
BBcXSJit0/nPkdxapXtdBhZLqC9sgRs3wAA8rS3xdlbw3m+qnsh+GtX9YTOVFPSD
521hUl6202bB540W7N182flmoqGS0/AuwD4rYeRZa1eKARnP05r8vXWFQmKviHjG
MwslV10UqgDFtDJ078pKJP88uNqG04EbLowE9kxLp6mm/cfknBTHF+NinDfrzEYt
eh8xpKiED7RQDlhsUlbLhDblLIS2EYee3hJu2ZvkwRBUHa89WnPdN/8zLRlR3HZx
pF8us/gEH/w=
=/3dj
-----END PGP SIGNATURE-----

--=-pa124ZuN84ifUWHP9URQ--
