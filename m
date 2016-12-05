From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 11:15:16 +0100
Message-ID: <20161205101516.GA24936@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >>In the ring, some descriptors can raise the irq (according to a
> >>threshold) and set the IC bit. In this path, the NAPI  poll will be
> >>scheduled.
> >
> >Not NAPI poll but stmmac_tx_timer(), right?
>=20
> in the xmit according the the threshold the timer is started or the
> interrupt is set inside the descriptor.
> Then stmmac_tx_clean will be always called and, if you see the flow,
> no irqlock protection is needed!

Actually, I was wrong. irqlock protection is needed, since
stmmac_tx_clean() is called from timer, and that's interrupt context,
as you can confirm using BUG_ON(in_interrupt());

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

iEYEARECAAYFAlhFPjQACgkQMOfwapXb+vKAGACfamFuk80BY35hKic3g31zD1uQ
flAAn1qTFG9LgRzntwv1c1MHCp1xETT9
=Quy3
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
