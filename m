From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 Jul 2012 13:08:48 +1000
Message-ID: <20120710130848.1014fbe05e5146a33a3c7d39@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__10_Jul_2012_13_08_48_+1000_dItsTebWZ=nA+19P"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?IkJqw7hybiBNb3JrIg==?= <bjorn@mork.no>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__10_Jul_2012_13_08_48_+1000_dItsTebWZ=nA+19P
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/usb/qmi_wwan.c:381:13: error: 'qmi_wwan_unbind_shared' undeclar=
ed here (not in a function)

Caused by a bad automatic merge between commit 6fecd35d4cd7 ("net:
qmi_wwan: add ZTE MF60") from the net tree and commit 230718bda1be ("net:
qmi_wwan: bind to both control and data interface") from the net-next
tree.

I added the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 Jul 2012 13:06:01 +1000
Subject: [PATCH] net: fix for qmi_wwan_unbind_shared changes

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/usb/qmi_wwan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 06cfcc7..85c983d 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -378,7 +378,7 @@ static const struct driver_info qmi_wwan_force_int2 =3D=
 {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 	.data		=3D BIT(2), /* interface whitelist bitmap */
 };
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__10_Jul_2012_13_08_48_+1000_dItsTebWZ=nA+19P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP+5zAAAoJEECxmPOUX5FErNgP/jl2wujt/Zm/89preMXdXmrM
9OmiuQ3yLBOw/dETQVfIMt6CO6TRyauVZKprjAaG8vfwGgcOLh2hhPlSJj73ZnUX
FPrjg/TFjLRn5JNULQQLqdRbqJZikBUGhfmPuYmELbeRAKGaLha+P42ZzHN4/EgQ
4ad0GivftsBf0bGpdsXrZhWjg1nsRSwvsFDRidpJtvqb1B/fOVBQBxpbNTTJQxqj
W1TAkrR39zMMamdgPCtaeH1vpITZ2IiKC4I928DhulfRws00xqRIcBkohyNcLoVi
gJYV7h+bFvTmUJxGPAIdd7M/kr4kgRKV3oV4uhe/WwWXNbdXs1NM0DCGVwiyllOv
5Lo27xdXijeQ3bsB3vFWr1AcYQNLYO2Jkn7ZCIr5LCUbJltmADuyH1uTp3IV2UCb
RzMqmQAMyZUW92eUPFdv8xiJkvR6uI8mZGnbYRPrMaBIb2J2RRERw23RNyiguhnI
vYUOx4cMW+pGgEVpzlOnjegufKCSP+401ej8gxaxkgnq5dvMGwZ54QJGnXQejCkK
cfOIDCRV8WD+eVnhv2Ty6AsFwn3u83iYgLhtSK0Ih6NWnvWnFPzrbGDZphBbEHVL
DfpkbKP8ZIbsZBj3CmsthkAe84YAvhxprBtmRKV5tw1M7OU12RCEp3B0rP0O23vG
lFy1D3cgVs9JY+8uQBf4
=VGgG
-----END PGP SIGNATURE-----

--Signature=_Tue__10_Jul_2012_13_08_48_+1000_dItsTebWZ=nA+19P--
