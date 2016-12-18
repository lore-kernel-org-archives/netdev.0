From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sun, 18 Dec 2016 21:16:35 +0100
Message-ID: <20161218201635.GB7886@amd>
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
        protocol="application/pgp-signature"; boundary="oC1+HKm2/end4ao3"
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


--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > For the same reason it's broken if it races with the transmit path: it
> > can release driver resources while the transmit path uses these.
> >=20
> > Btw the points below may not matter/hurt much for a proof a concept
> > but they would need to be addressed as well:
> > 1) unchecked (and avoidable) extra error paths due to stmmac_release()
> > 2) racy cancel_work_sync. Low probability as it is, an irq + error could
> >    take place right after cancel_work_sync
>=20
> It was indeed only meant as a proof of concept. Nevertheless the race is =
not=20
> good, since one can run into it when faking the tx error for testings pur=
poses.
> So below is a slightly improved version of the restart handling.
> Its not meant as a final version either. But maybe we can use it as a sta=
rting
> point.

Certainly works better than version we currently have in tree. I'm
running it in a loop, and it survived 10 minutes of testing so
far. (Previous version killed the hardware at first iteration.)

> Again the patch is only compile tested.

Tested-by: Pavel Machek <pavel@denx.de>

Thanks!
								Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--oC1+HKm2/end4ao3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhW7qMACgkQMOfwapXb+vI64ACguc6TxTlGT7DEvjdXuRhDc+NA
Yj4An1sqO1Q57b4zow4cH+lOLzTB1J4B
=hhjR
-----END PGP SIGNATURE-----

--oC1+HKm2/end4ao3--
