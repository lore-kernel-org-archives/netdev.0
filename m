From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sun, 18 Dec 2016 18:23:35 +0100
Message-ID: <20161218172335.GA31650@amd>
References: <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
 <20161217173150.GA20231@amd>
 <20161218001507.GA5343@electric-eye.fr.zoreil.com>
 <a2cbcfcd-f377-565c-a21c-3daa3abce519@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a2cbcfcd-f377-565c-a21c-3daa3abce519@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > - e1efa87241272104d6a12c8b9fcdc4f62634d447
>=20
> Yep, a sync of the dma descriptors before the hardware gets ownership of =
the tx tail
> idx is missing in the stmmac, too.=20

Thanks for the hint. Actually, the driver uses smp_wmb() which is
completely crazy, and probably misses rmb() in clean_tx, too. Anyway,
I did not notice there are dma_ variants, too... we clearly need them.

Thanks and best regards,
								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhWxhcACgkQMOfwapXb+vKZbACghNuLkffoqy3n72Fii5xI2u06
BncAoJd7DHdyoa5J7FOXOn8QaFmH+Lh1
=GaTd
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--
