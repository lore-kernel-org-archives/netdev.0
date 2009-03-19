From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Required sequence to set wireless parameters? (was:
 2.6.29-rc8: Reported regressions from 2.6.28)
Date: Thu, 19 Mar 2009 17:53:50 +0100
Message-ID: <1237481630.5100.92.camel@johannes.local>
References: <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <1237455534.5100.56.camel@johannes.local>
	 <20090319141311.GA3587@tuxdriver.com>
	 <200903191602.58790.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-k25saOD3Tw6lWyrUnp4H"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	jeff.chua.linux@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58451 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbZCSSAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 14:00:22 -0400
In-Reply-To: <200903191602.58790.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-k25saOD3Tw6lWyrUnp4H
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-03-19 at 16:02 +0100, Frans Pop wrote:

> Mostly just curious, but is that actually required by some wireless=20
> standard? If not, is it really reasonable to ask userland to do things in=
=20
> that particular order?

Wext is a mess, and we've known that for a long time... But no, the
sequence should _not_ be required, it's just _easier_ for the kernel,
and as such has a better probability of succeeding if there are
problems, it should still work though.

However, one thing that will _not_ work is this:

iwconfig wlan0 essid xyz
iwconfig wlan0 key s:xyz

you still need

iwconfig wlan0 ap any

or anything similar after setting the key to trigger the kernel to do
something.

> Reason I ask is that for example when writing wireless support for e.g. a=
=20
> distro installation system, it seems most logical to *first* ask the user=
=20
> what network (ESSID) he wants to connect to. Next to check if we can=20
> connect to that network without additional authentication and only then,=20
> if needed, ask for keys etc.
> If it's not possible to set that info in that logical order that seems=20
> rather restrictive to me and would probably mean that you'd have to reset=
=20
> AP, ESSID and possibly other settings before each incremental attempt.

That's a pretty wrong argument, nothing says your software cannot
collect all the information and then give it to the kernel at once
later, I think... In fact, this is required anyway when you use RSN or
WPA (wpa_supplicant needs all information at once), for example.

johannes

--=-k25saOD3Tw6lWyrUnp4H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJwnicAAoJEKVg1VMiehFYvX4QAJZlB90q2bTsks5+lvKz3DBK
88ZcByaRAVd4CtMD2LkLgVwc97CuXsR29rCszrsZIh6pa1/4Gnbqq53EhD1p+Tuf
Byh4eTeUGuEiJTd8RJelZnDeLVzWgc1Vf9smuSd8loyc8p6prBKEjzwNacBADgcW
n52BQPdr4oYM62gBqpWB18jIv16Oqru9Q3yC5MJGIxxE+E4y+zDpUmvCtq1Dlazj
blgsRoB+bmoHo6Ws7pOmC1K6Z1g/j72Q5Ighub8sOkRRj9ASFXa1TKofN18npch/
2jmcNiZajziX7hDJXuwZXwO3TVWcx7EHxymSE11ZK/+91Ddozijo2sq7UD66JUsD
vOBa1xaW2sCLBlLpAxDvkt/QnBMhCi4KJY9S/3FqEC3hVqKFCvBtGTmdEY6mrCGo
mIKolBmpo0IT/GGMEuns011o6Wqftybv3Ntl7nvu2Cxa2Jwv+2f41kd8ewoIJhYV
g1d2/q/tyevIVx/r1LG5XZpNtYAG5a+5Kmn5tWq20p22kx8KuyZsQ9b7WgUvqkbk
j8M+pICgwljjYCLuWGE34tXQq2HwRsRWGJVNYuztJZZOLpeXTXwcDD8LXuz4czkW
oZMhqLSHIxkuyHpq9/jPk33x7bXQwi8EbNiXh0W2ho5a3nDQrc9tSJKlPgVZKFmq
v6vfrF3YqZVySgPk93k3
=2gHF
-----END PGP SIGNATURE-----

--=-k25saOD3Tw6lWyrUnp4H--

