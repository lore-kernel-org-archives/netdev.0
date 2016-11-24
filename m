From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac ethernet: unify locking
Date: Thu, 24 Nov 2016 11:46:19 +0100
Message-ID: <20161124104619.GA30723@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124102901.GA27793@amd>
 <20161124103630.GB27793@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124103630.GB27793@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Make locking match in both _xmit functions.
  =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 0363db3..1cff258 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2185,12 +2185,12 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 	spin_lock(&priv->tx_lock);
=20
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
-		spin_unlock(&priv->tx_lock);
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
 			pr_err("%s: Tx Ring full when queue awake\n", __func__);
 		}
+		spin_unlock(&priv->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
=20

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2xPsACgkQMOfwapXb+vKNhACfaaJH+wlVKawDT3eEUECraW2L
xzIAnRM6If4DdYAy/0O4fI80Z78BiHWN
=aXNg
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
