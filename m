From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Re: Synopsys Ethernet QoS
Date: Wed, 14 Dec 2016 12:54:24 +0100
Message-ID: <20161214115424.GA27011@amd>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>, larper@axis.com,
        rabinv@axis.com, netdev <netdev@vger.kernel.org>,
        CARLOS.PALMINHA@synopsys.com, Jie.Deng1@synopsys.com,
        Stephen Warren <swarren@nvidia.com>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:39039 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753100AbcLNLy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 06:54:28 -0500
Content-Disposition: inline
In-Reply-To: <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> There are some performance problems with the stmmac driver though:
>=20
> When running iperf3 with 3 streams:
> iperf3 -c 192.168.0.90 -P 3 -t 30
> iperf3 -c 192.168.0.90 -P 3 -t 30 -R
>=20
> I get really bad fairness between the streams.
>=20
> This appears to be an issue with how TX IRQ coalescing is implemented in =
stmmac.
> Disabling TX IRQ coalescing in the stmmac driver makes the problem go awa=
y.

Yes, I'm hitting the same problem

https://lkml.org/lkml/2016/12/11/90

> Also netperf TCP_RR and UDP_RR gives really bad results compared to the
> dwceqos driver (without IRQ coalescing).
> 2000 transactions/sec vs 9000 transactions/sec.
> Turning TX IRQ coalescing off and RX interrupt watchdog off in stmmac
> gives the same performance. I guess it's a trade off, low CPU usage
> vs low latency, so I don't know how important TCP_RR/UDP_RR really is.

Well... 75% performance hit is a bug, plain and simple, not CPU tradeoff.

> The best thing would be to get a good working TX IRQ coalesce
> implementation with HR timers in stmmac.

Actually it seems that using HR timers is not the only problem, AFAICT
the logic is wrong way around. (But yes, it needs to be HR timer, too,
and probably packet count needs to be reduced, too.)

Best regards,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhRMvAACgkQMOfwapXb+vJZeQCaA64Ipenqy5bA4xEVS/UaJ9VW
3HkAoMByi1lgsEP+e5uAdZC6led0bpBs
=/3V5
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
