From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 7/8] rds: Pass pointers to virt_to_page(), not integers
Date: Sun, 27 Oct 2013 21:54:16 +0000
Message-ID: <1382910856.2994.51.camel@deadeye.wl.decadent.org.uk>
References: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-80YuffHdy/BwCL6uL+by"
Cc: LKML <linux-kernel@vger.kernel.org>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-80YuffHdy/BwCL6uL+by
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Most architectures define virt_to_page() as a macro that casts its
argument such that an argument of type unsigned long will be accepted
without complaint.  However, the proper type is void *, and passing
unsigned long results in a warning on MIPS.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/rds/message.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index aba232f..1913fc9 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -257,7 +257,7 @@ struct rds_message *rds_message_map_pages(unsigned long=
 *page_addrs, unsigned in
=20
 	for (i =3D 0; i < rm->data.op_nents; ++i) {
 		sg_set_page(&rm->data.op_sg[i],
-				virt_to_page(page_addrs[i]),
+				virt_to_page((void *)page_addrs[i]),
 				PAGE_SIZE, 0);
 	}
=20


--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-80YuffHdy/BwCL6uL+by
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUm2LiOe/yOyVhhEJAQrn9A/+IrG6+cmRsnwMPVCG/j2GRnJ3fhTYL3Hq
HZbxTKojCDfzLvlLrOVd+Mggtk8QCZXfZQrrUnz9/wUfysoGQEcQ/0Z1iVR7vEC7
K7ouGl3FbEJnIdGG376aSZJjN+OZ6hA1o/ue9F5tE09lu0Dw/8Snrs+9gFyIZEf1
stw6KoVPDQ5eI7HuHdbhiaT6yPLAoelQa3xIe7q+EIuoLOGs7DgXqv3A26VSMAOC
VdsJdRv+nxPo0fVzJpOHrJQz3Cz8J/+BF+FB6L+3x4lHiUQQlIH51LuPggiLe/fG
yO0hvP5EDOcWhWHKWu6W1XE1J4O0rZ0DbajNcBzpWjlYIYy4SQ+sLdjvj3V1wf4Q
K5dqd8xyef1ZTG5VdPCG2lwSMgLDvNWJ1G1IP1JC5IhWoSgqzl90Hrp+P2boMgL+
1k60Agz3zyDgJENZq8gCvn5FhGElCFiTWvxzduwafGIcaW4PXCj+RXQJEmEC/R92
L5x/M6Jnd8HeSr9kKjVci6yr/oXpKGu72LTH5xzKR8eif3TF9e4Lxe34KfZNDZaY
EF78S/9mrBzvLPqb+FGrS3/4mFySx/k0fQAwKPIbznhELr3BgyHezUkHNr3d5ZQl
j4vf/Na/Q9dWhr7wweKANSs89ttERqEA25vR0y/nk6G+JgokmbSRI3dnpLJd2qe4
XPhJu9cWh4I=
=yOzY
-----END PGP SIGNATURE-----

--=-80YuffHdy/BwCL6uL+by--
