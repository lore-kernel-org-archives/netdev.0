From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Thu, 5 Apr 2012 13:25:15 +1000
Message-ID: <20120405132515.e61465875407a452c1a6f78e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Apr_2012_13_25_15_+1000_S0_mNpNGK6m/5R5r"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Deepak SIKRI <deepak.sikri@st.com>,
	Shiraz Hashim <shiraz.hashim@st.com>,
	Vikas Manocha <vikas.manocha@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Apr_2012_13_25_15_+1000_S0_mNpNGK6m/5R5r
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c: In function 'stmmac_=
probe_config_dt':
drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:53:7: error: 'struct =
plat_stmmacenet_data' has no member named 'pbl'

Caused by commit 8327eb65e795 ("stmmac: re-work the internal GMAC DMA
platf parameters").  Clearly I am missing something, because I can't see
how that patch is correct since nothing ever assigns to the new dma_cfg
pointer but it is dereferenced.

I have added this patch to make it build today, but it is obviously not
correct.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 5 Apr 2012 13:19:21 +1000
Subject: [PATCH] stmmac: hack to make it build

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 116529a..1e4d12d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -50,7 +50,7 @@ static int __devinit stmmac_probe_config_dt(struct platfo=
rm_device *pdev,
 	 * once needed on other platforms.
 	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac")) {
-		plat->pbl =3D 8;
+/*		plat->pbl =3D 8; */
 		plat->has_gmac =3D 1;
 		plat->pmt =3D 1;
 	}
--=20
1.7.10.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__5_Apr_2012_13_25_15_+1000_S0_mNpNGK6m/5R5r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPfRCbAAoJEECxmPOUX5FEkIQP/iztn+Uo115joDNVN1H+6j3x
MI0U8ywdPmgVsXVI8Xz0lsYQAYim5iixU2qIqKNs90wLXN5zd+vZgkxCcaLgqWnx
tQM33C0nbcv0tgOxcuH2wg9jibD0kk6nqBhb47tMrsdR5eab4caBqP3VuZWYgaDZ
YAuYBOB0yVszl2fTaLd8bSXPLV0C5IgGxpOJ7h8Gf2gmexhXQUkyB9J6xx4ocmmH
AJAkaCaHtapQPEpDKJ5hOsonD/0y+BUtbtWCmUjp8V4bNgpXSujqmAPYlTrLhMxv
8RnQZhOdlPz9Fta8wPybZHwZeyGtYMR8iE+zNCURx7mC02RSKjMSwLqeyJJTi0ma
tB7LPj/2VjBZyjWOb95ml/NKqBDeECuKILT47MHNfNrma/jpodaZqYUmpteu5/kY
VEko3ve6puqC4iZOGxvxZ/98g0wKt3nkM/Hof0MOBgr0cCMx0if2/nDAiFAsWaXo
kHgAP0M8g2OuzlDhiv98KuTPyvSQ73LnHJzcTdS814Z4qbuWSQ3KRt3GBnFKnrf2
8U8yBytV9y6N0k6LE+vWz2ef5iV6zfiiCUOPzHj7Au0wvP3BTTLFHGV696/lLDx+
pJ0HyfUZt0EfhNBsPjiorxE+S6YgSJPQuogWUFzBh8k0HLwHBSYwxqAI9/KtFCyk
wd6HmfjgO75npY3WsX87
=OXcA
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Apr_2012_13_25_15_+1000_S0_mNpNGK6m/5R5r--
