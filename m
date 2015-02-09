From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 9 Feb 2015 14:07:45 +1100
Message-ID: <20150209140745.24859389@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ADFK9_qy718Hu0MStAXZsTG"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ADFK9_qy718Hu0MStAXZsTG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

lib/rhashtable.c: In function 'rhashtable_walk_next':
lib/rhashtable.c:1002:3: error: implicit declaration of function 'ERR_PTR' =
[-Werror=3Dimplicit-function-declaration]
   return ERR_PTR(-EAGAIN);
   ^
lib/rhashtable.c:1002:3: warning: return makes pointer from integer without=
 a cast

Caused by commit f2dba9c6ff0d ("rhashtable: Introduce
rhashtable_walk_*"). See Rule 1 in Documentation/SubmitChecklist.

I have added the following fix patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Feb 2015 14:04:03 +1100
Subject: [PATCH] rhashtable: using ERR_PTR requires linux/err.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 lib/rhashtable.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e96fc00208bc..9cc4c4a90d00 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -23,6 +23,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <linux/rhashtable.h>
+#include <linux/err.h>
=20
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4UL
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/ADFK9_qy718Hu0MStAXZsTG
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2CSFAAoJEMDTa8Ir7ZwVhVYP/ip0KrzOI2/6Av1S6GtKhTW4
qaOTwtPuCWXOHQr3O1Cng3KZmPHytU+SHocllOBU58aaRsuUgIybJGhCSJcoOj4m
M27cYNIQ8eKgmvckJ/k50dXlTz269vBeMvrwq5DXTeQc4SIelpTBAyMLvAfYuXPY
BImVatrUAJ7FRYBM2LL8ezXX+g0/Y1whXKQIxDplldex1qVlh0DlBN8cvd8NCSwU
Zlhv7nMj2Vma9h/IhwV3DDJ93yzTNQXebbpvU6CpnzZzdIIeJV6G1d95GcxaPQDh
8hl/8cZas18eKa9DJ9gmCjYK7scVG7V1Z5CdZi3mzYdO3SbDpvNk+iM4sKlq1caw
GLSzqnRJotQALh392i9c1sW/QUROAD+KIM2JDzMK5KThwM1ceJcMrNqPACCApvXJ
wVYupp3XYBeIMsOUAMuNjoHnDUuDJPwQpXRX13vicDi4vPAbO0/df0D0L06mnHEN
6JgTOXpeiqKXnD4obeVaHyI2UDPmCfCajcb+EXLuNgZVLFx/gaL8tmpuiZjueEEt
OFP9aLEqQPIkduWdK3tOCw+achE6Z1G6qlWp5kqkeDpnzxkPGppL2vFR/Im0C5m5
3ixLvw/rgaqzz3JHydikyVOEhQLTsmBrPVntCmbD1FajDe2WE+tp4k/gRTapv59X
i/fwmGK7l3SXW1M+ANK5
=/5bR
-----END PGP SIGNATURE-----

--Sig_/ADFK9_qy718Hu0MStAXZsTG--
