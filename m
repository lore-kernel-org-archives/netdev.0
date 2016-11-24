From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Thu, 24 Nov 2016 09:55:06 +0100
Message-ID: <20161124085506.GA25007@amd>
References: <20161123105125.GA26394@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161123105125.GA26394@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> I'm debugging strange delays during transmit in stmmac driver. They
> seem to be present in 4.4 kernel (and older kernels, too). Workload is
> burst of udp packets being sent, pause, burst of udp packets, ...
>=20
> Test code is attached, I use these parameters for testing:
>=20
> ./udp-test raw 10.0.0.6 1234 1000 100 30
>=20
> The delays seem to be related to coalescing:
>=20
> drivers/net/ethernet/stmicro/stmmac/common.h
> #define STMMAC_COAL_TX_TIMER    40000
> #define STMMAC_MAX_COAL_TX_TICK 100000
> #define STMMAC_TX_MAX_FRAMES    256
>=20
> If I lower the parameters, delays are gone, but I get netdev watchdog
> backtrace followed by broken driver.
>=20
> Any ideas what is going on there?

4.9-rc6 still has the delays. With the

#define STMMAC_COAL_TX_TIMER 1000
#define STMMAC_TX_MAX_FRAMES 2

settings, delays go away, and driver still works. (It fails fairly
fast in 4.4). Good news. But the question still is: what is going on
there?

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2quoACgkQMOfwapXb+vJ7ZQCeMJwfg73Fm1OaV85vfOLdrJCg
MjAAn1smRSFYx2v8g4c9nnELcokTj9+R
=32Wu
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
