From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sat, 3 Jan 2015 14:01:45 +1100
Message-ID: <20150103140145.3cd6b79c@canb.auug.org.au>
References: <20150103091101.04b2c11e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/znWSccTcOy8hr3rl/cMSN4R"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150103091101.04b2c11e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/znWSccTcOy8hr3rl/cMSN4R
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Sat, 3 Jan 2015 09:11:01 +1100 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
>=20
> drivers/net/ethernet/mellanox/mlx4/en_clock.c: In function 'mlx4_en_init_=
timestamp':
> drivers/net/ethernet/mellanox/mlx4/en_clock.c:249:2: error: implicit decl=
aration of function 'CLOCKSOURCE_MASK' [-Werror=3Dimplicit-function-declara=
tion]
>   mdev->cycles.mask =3D CLOCKSOURCE_MASK(48);
>   ^
> drivers/net/ethernet/mellanox/mlx4/en_clock.c:257:3: error: implicit decl=
aration of function 'clocksource_khz2mult' [-Werror=3Dimplicit-function-dec=
laration]
>    clocksource_khz2mult(1000 * dev->caps.hca_core_clock, mdev->cycles.shi=
ft);
>    ^
> drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c: In function 'ixgbe_ptp_star=
t_cyclecounter':
> drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c:796:2: error: implicit decla=
ration of function 'CLOCKSOURCE_MASK' [-Werror=3Dimplicit-function-declarat=
ion]
>   adapter->cc.mask =3D CLOCKSOURCE_MASK(64);
>   ^
>=20

My powerpc allyesconfig build also produced this:

drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function 'bnx2x_init_c=
yclecounter':
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:14613:2: error: implicit d=
eclaration of function 'CLOCKSOURCE_MASK' [-Werror=3Dimplicit-function-decl=
aration]
  bp->cyclecounter.mask =3D CLOCKSOURCE_MASK(64);
  ^

So I added this patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Sat, 3 Jan 2015 12:15:37 +1100
Subject: [PATCH] bnx2x: Include clocksource.h to get CLOCKSOURCE_MASK

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net=
/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2c951326a85d..119c190721da 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -57,6 +57,7 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
+#include <linux/clocksource.h>
=20
 #include "bnx2x.h"
 #include "bnx2x_init.h"
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/znWSccTcOy8hr3rl/cMSN4R
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUp1udAAoJEMDTa8Ir7ZwVRMkP/iJ4ewJJT3FY4Jk/mGquAfsm
LJwmkeC6WrR+sJHf3jtWM8M9uiZzGh9O4TcS9Otg9oc/Kw4SuKYxI50dGR/TQFQ/
b+uH1g/rY38v2GThRWxHtmwcnwCS0RPElY9FJWjsgS7MewnNvpjAuIzlE+z6jTRF
HtOcuqU0uP+d0nEJXDnym7Z3j6kO442Z72/Xk+86dOB7w36Hjp69uQ9zR+h+sMrG
2GqG9wTCIRI0owsGLc/ICw5yUtoCeqIoE9qNR8Dgh4v+jp8jM+Xruh9+f9p5ALk0
NS9Gwu5z+rYNC16i40P1N8ON4Rq+PjjA4anluc5Z9PBDODu4L77Uy9p4jWFJXLrj
x44ISFlpoUvjxRnGbiuN+rYNJihQFaoKVKSsJjdZ2ek+es1aZJf1raEB0bDRg7Mk
m8XrHl/mB3bDd3xkOlOT5zqJjehNbg0AeN0KlV4XDLRHhYOxIalIGKm8MMeCDwwo
WjgGs0eEl5zqArlFO6INStcX0jDP2tyLEYpHtNYeaOi5H3EGF8VEY7dBuajfqY+J
grSOoXUY0KWbLfVGv5pNYodwm521BBSDijgacFAP7burgI/WkXEdBAHMEXzWEKXR
+/jUBGKmI2S8k0Z275JRkMvS38/NPjRdGvdzQGsqYcT48UCx7dmCH4b8DpVZ4TjZ
7eYXd92n5NaJ+o1422Dk
=UE9R
-----END PGP SIGNATURE-----

--Sig_/znWSccTcOy8hr3rl/cMSN4R--
