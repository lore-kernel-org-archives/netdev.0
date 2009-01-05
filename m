From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Mon, 05 Jan 2009 14:31:15 +0100
Message-ID: <1231162275.3334.20.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 <1231085150.3296.3.camel@johannes>
	 <20090104162826.GT496@one.firstfloor.org>
	 <1231087288.3296.15.camel@johannes>
	 <20090104174339.GX496@one.firstfloor.org>
	 <1231090388.3296.17.camel@johannes>
	 <20090104184136.GY496@one.firstfloor.org>
	 <1231144574.3286.15.camel@johannes>
	 <20090105132141.GO496@one.firstfloor.org>
	 <1231161379.3334.14.camel@johannes>
	 <20090105133657.GQ496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DvWnUYcEGC2uZrqP/m0U"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, davem <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44722 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbZAENaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:30:35 -0500
In-Reply-To: <20090105133657.GQ496@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DvWnUYcEGC2uZrqP/m0U
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-01-05 at 14:36 +0100, Andi Kleen wrote:
> On Mon, Jan 05, 2009 at 02:16:19PM +0100, Johannes Berg wrote:
> > > I didn't use any monitoring with this. No tcpdump, no wireless
> > > sniffer tools or anything. It happened all the time during
> > > normal operation.
> >=20
> > You did have a monitor interface up though, didn't you? If nothing
>=20
> wmaster0 was up. Is that a monitoring interface?=20

No. Only if you do iwconfig ... mode monitor or use iw to create one or
something like that.

I was under the impression that you only modified monitor mode code, but
upon closer inspection (really, you should diff with -p, makes it a lot
easier to review) it seems that you also touched packet defragmentation
code. Are you running a low fragmentation threshold on your network?

Can you
check /sys/kernel/debug/ieee80211/phy*/statistics/rx_expand_skb_head*
please?

> > actually used those skbs then it's likely that the warning didn't resul=
t
> > in any corruption at all.
>=20
> Nothing was corrupted ever to my knowledge, just lots of spam in my kerne=
l logs.

You wouldn't easily notice any socket memory charge corruption anyway.

johannes

--=-DvWnUYcEGC2uZrqP/m0U
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYgugAAoJEKVg1VMiehFYxEQP/jC8XXfLGyix9j1bCSAH2ZsH
raZUXdcA4xAI4hrHF4EjtBu6+16M4QTcc52dw1GRehCxpZLFPB5x3pmNh7wWw5+A
QcvkjnImtaAnzMZQ4gXTGj3r0S73cNXP2EPcKpqOSIG8psnJxHIejgZHRaWaWP/q
++EU5psKNSpoOkSJk/WDw/At15lXFwYZ/xpcCg9Nzvaf0H+wQn8ydDU4FBfZjyQF
4c+Um/ZCSrX12Sy0iRLmpdpGtGLMtGvaDx2Ve5D7fBMGnrGWSMLz+beJmT1o8qc0
lJD6GmF/xySQDPaqkSFJrnoyr5pgxTfDwycP4OiyQSgf1spzctlhzkbOnXvBsGL0
vLiwkMlgU1N4G+ux8j9fnTvbfwGpfr3OnxK9JBWoHb5IRrC2TemeQ9TzMJ9KcB9V
38eaSDX80TrkKFGnbPcLnGeCgCgutS4uXtjR2sGwWXApXQ3JFWJYA0vC+dqO4iJc
l+3WgAAEIUdDUf73Jf4H+vzncKx52Lo2fRwV+2QkadJTo5wenVek2KaQAkulpIFO
93/I+jL/T8COeo3jRNPIb07D0Q3SV+ISf7g3m6ns3wfSBDLQCvFlyxPn+usTyrPP
hOlZcwEViLnoOYrFUlBsc6j+i+JILfQ50cAhfasIb93/VxZrBb4JuOQ2qUV75Eve
LZ6cnlZCQ0Eoov3pdGpW
=H+NJ
-----END PGP SIGNATURE-----

--=-DvWnUYcEGC2uZrqP/m0U--

