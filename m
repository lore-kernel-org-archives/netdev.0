From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Synopsys Ethernet QoS
Date: Wed, 14 Dec 2016 13:57:35 +0100
Message-ID: <20161214125735.GA19542@amd>
References: <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qDbXVdCdHGoSgWSk"
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, larper@axis.com,
        rabinv@axis.com, netdev <netdev@vger.kernel.org>,
        CARLOS.PALMINHA@synopsys.com, Jie.Deng1@synopsys.com,
        Stephen Warren <swarren@nvidia.com>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:40952 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755709AbcLNNDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 08:03:43 -0500
Content-Disposition: inline
In-Reply-To: <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> So if there is a long time before handling interrupts,
> I guess that it makes sense that one stream could
> get an advantage in the net scheduler.
>=20
> If I find the time, and if no one beats me to it, I will try to replace
> the normal timers with HR timers + a smaller default timeout.
>=20

Can you try something like this? Highres timers will be needed, too,
but this fixes the logic problem.

You'll need to apply it twice as code is copy&pasted.

Best regards,
									Pavel

+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c

 	 */
 	priv->tx_count_frames +=3D nfrags + 1;
 	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-		mod_timer(&priv->txtimer,
-			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+		if (priv->tx_count_frames =3D=3D nfrags + 1)
+			mod_timer(&priv->txtimer,
+				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 	} else {
 		priv->tx_count_frames =3D 0;
 		priv->hw->desc->set_tx_ic(desc);


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--qDbXVdCdHGoSgWSk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhRQb8ACgkQMOfwapXb+vJtvQCfcmhDxEEMAnpwYVIgktYGAeqo
ibMAn2qkY5HbyY6T4pepWSjefwavhbRX
=Omc2
-----END PGP SIGNATURE-----

--qDbXVdCdHGoSgWSk--
