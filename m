From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Thu, 8 Dec 2016 16:46:11 +0100
Message-ID: <20161208154611.GB24327@amd>
References: <20161207213757.GC2250@amd>
 <20161207.184111.1365236213357532881.davem@davemloft.net>
 <20161208140846.GA24327@amd>
 <20161208.102641.2159772626439340664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="IiVenqGWf+H9Y6IX"
Cc: LinoSanfilippo@gmx.de, bh74.an@samsung.com, ks.giri@samsung.com,
        vipul.pandya@samsung.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161208.102641.2159772626439340664.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-12-08 10:26:41, David Miller wrote:
> From: Pavel Machek <pavel@ucw.cz>
> Date: Thu, 8 Dec 2016 15:08:46 +0100
>=20
> > On Wed 2016-12-07 18:41:11, David Miller wrote:
> >> From: Pavel Machek <pavel@ucw.cz>
> >> Date: Wed, 7 Dec 2016 22:37:57 +0100
> >>=20
> >> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> > index 982c952..7415bc2 100644
> >> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> > @@ -1308,7 +1308,7 @@ static void stmmac_tx_clean(struct stmmac_priv=
 *priv)
> >> >  	unsigned int bytes_compl =3D 0, pkts_compl =3D 0;
> >> >  	unsigned int entry =3D priv->dirty_tx;
> >> > =20
> >> > -	spin_lock(&priv->tx_lock);
> >> > +	netif_tx_lock_bh(priv->dev);
> >> > =20
> >> >  	priv->xstats.tx_clean++;
> >> > =20
> >>=20
> >> stmmac_tx_clean() runs from either the timer or the NAPI poll handler,
> >> both execute from software interrupts, therefore _bh() should be
> >> unnecessary.
> >=20
> > I've tried the test again with netif_tx_lock() (not _bh()) and it
> > survived for more then four hours. Strange...
>=20
> It's not strange, it's completely expected.

Well, I tried that exact test before, and it survived for something
like 10 minutes. So yes... this surprised me.
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--IiVenqGWf+H9Y6IX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhJgEIACgkQMOfwapXb+vJbIwCfX0EnABLxHqdo29/jDFMpccqY
hH8AoJIhZwJs/2N1jlpqwv9rzgIC9Gjt
=1gi6
-----END PGP SIGNATURE-----

--IiVenqGWf+H9Y6IX--
