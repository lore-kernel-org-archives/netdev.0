From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 13:01:36 +0100
Message-ID: <20161205120136.GC16126@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161202123241.GA5869@amd>
 <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="jousvV0MzM2p6OtC"
Cc: alexandre.torgue@st.com, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jousvV0MzM2p6OtC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >>We had experimented this tuning on STB IP where just datagrams
> >>had to send externally. To be honest, although we had seen
> >>better results w/o any timer, we kept this approach enabled
> >>because the timer was fast enough to cover our tests on SH4 boxes.
> >
> >Please reply to David, and explain how it is supposed to
> >work... because right now it does not. 40 msec delays are not
> >acceptable in default configuration.
>=20
> I mean, that on UP and SMP system this schema helped
> to improve the performance saving CPU on my side and this has been
> tested since a long time (~4 years).
> I tested something similar to yours where unidirectional traffic
> with limited throughput was needed and I can confirm you that
> tuning/removing coalesce parameters this helped. The tuning I decided
> to keep in the driver was suitable in several user cases and if now
> you have problems or you want to review it I can just confirm that
> there are no problems on my side. If you want to simply the logic
> around the tx process and remove timer on official driver I can accept
> that. I will just ask you uto double check if the throughput and
> CPU usage when request max throughput (better if on GiGa setup) has
> no regressions.
> Otherwise we could start thinking about adaptive schema if feasible.

Ok, so you see the issue. Good.

See the other email to description how it could be fixed... the logic
is broken. How it was not discovered for 4 years is mystery to me.
=20
> >Agreed that no irqlock protection is needed if we rely on napi and timer=
s.
>=20
> ok

Actually I was wrong there. Another reason to disable tx coalescing
until it is fixed.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--jousvV0MzM2p6OtC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFVyAACgkQMOfwapXb+vKdtgCgjbMbKNmn7ZT6zWu9jSxbw5j4
tcMAoJt02D3IJ9yklQ1cvoRWUpS//EaO
=Hn/Z
-----END PGP SIGNATURE-----

--jousvV0MzM2p6OtC--
