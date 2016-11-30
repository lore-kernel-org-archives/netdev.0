From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: simplify flag assignment
Date: Wed, 30 Nov 2016 12:44:31 +0100
Message-ID: <20161130114431.GB14296@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="cmJC7u66zC7hs+87"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cmJC7u66zC7hs+87
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Simplify flag assignment.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index ed20668..0b706a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2771,12 +2771,8 @@ static netdev_features_t stmmac_fix_features(struct =
net_device *dev,
 		features &=3D ~NETIF_F_CSUM_MASK;
=20
 	/* Disable tso if asked by ethtool */
-	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
-		if (features & NETIF_F_TSO)
-			priv->tso =3D true;
-		else
-			priv->tso =3D false;
-	}
+	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen))
+		priv->tso =3D !!(features & NETIF_F_TSO);
=20
 	return features;
 }


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--cmJC7u66zC7hs+87
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg+u58ACgkQMOfwapXb+vIh9ACgmbK/R2Cv78z5LahS/YrkEKLF
z6IAnA3y+l9ZCTifPFMNt462pJPRAh03
=n5Ag
-----END PGP SIGNATURE-----

--cmJC7u66zC7hs+87--
