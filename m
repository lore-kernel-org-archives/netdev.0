From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 23:02:21 +0100
Message-ID: <20161205220221.GA19135@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161205101516.GA24936@amd>
 <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <trinity-efd00e93-2b37-4543-a199-e2cbed9fe455-1480937999976@3capp-gmx-bs18>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >=20
> > Actually, I was wrong. irqlock protection is needed, since
> > stmmac_tx_clean() is called from timer, and that's interrupt context,
> > as you can confirm using BUG_ON(in_interrupt());
> >=20
>=20
> in_interrupt() can mean both softirq and hardirq context. In this case it
> means softirq. So I guess you were right before, and no irq locking is ne=
eded.

Are you absolutely sure? Because my testing seems to indicate
otherwise (but I may have made a mistake).

According to

https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/c214.ht=
ml

we need spin_lock_bh at minimum, as we are locking user context
against timer.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhF4+0ACgkQMOfwapXb+vKCqACgoTqzIrl2YFvozduG2epyVzHd
PiYAnAyPKui7xtlNQmpw4gVzUUI5Lqc7
=+ilP
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
