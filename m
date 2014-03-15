From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 16/16] sfc: Don't receive packets when the napi
 budget == 0
Date: Sat, 15 Mar 2014 17:23:51 +0000
Message-ID: <1394904231.15764.34.camel@deadeye.wl.decadent.org.uk>
References: <871ty41dps.fsf_-_@xmission.com>
	 <87lhwcw9j9.fsf_-_@xmission.com>
	 <1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
	 <20140315.122912.1621610280186900725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vtRNivqj9iPwhgG5fa5T"
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43406 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755095AbaCORYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 13:24:04 -0400
In-Reply-To: <20140315.122912.1621610280186900725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vtRNivqj9iPwhgG5fa5T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-15 at 12:29 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sat, 15 Mar 2014 15:23:34 +0000
>=20
> > On Fri, 2014-03-14 at 18:11 -0700, Eric W. Biederman wrote:
> >> Processing any incoming packets with a with a napi budget of 0
> >> is incorrect driver behavior.
> >>=20
> >> This matters as netpoll will shortly call drivers with a budget of 0
> >> to avoid receive packet processing happening in hard irq context.
> >=20
> > But this also prevents handling TX completions, at which point you may
> > as well change efx_netpoll() to a no-op.  And then, does it make sense
> > to implement ndo_poll_controller at all?
> >=20
> > Note that sfc does have a module parameter to enable separate RX and TX
> > completions so they could be polled separately, but it is disabled by
> > default.
>=20
> TX completions should run unconditionally, irregardless of the given
> budget.
>=20
> This is how I have coded all of my drivers, and I how I tell others
> to do so.

The Solarflare hardware provides generic event queues for RX and TX
completions, link changes, errors, etc.  The driver can't process TX
completions without going through all the other events mixed in with
them.

It is possible to allocate separate event queues for TX completions but
that isn't done by default because it also requires extra IRQs.  The
driver could be restructured to allocate some event queues without IRQs
of their own, but it probably requires a lot of work.

Ben.

--=20
Ben Hutchings
When you say `I wrote a program that crashed Windows', people just stare ..=
.
and say `Hey, I got those with the system, *for free*'. - Linus Torvalds

--=-vtRNivqj9iPwhgG5fa5T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUySMp+e/yOyVhhEJAQqV9RAAyJ7LyD9+kT3fd/k5z5imnOormeXpjIyV
fGUBRVvs4kQ5X5RB+7dSYO58pvRQfPZc8nS3vIWWCTNJ8vXbmJrNULrShdugijsg
1ZDikXCGlH2KOcdLrLqkpxhxcAq3bvfjUYG4oEEic4X70Cj+Wuc2uxVWP61zMkRD
KrGvA9NJV+sfffrzOgyk7SntIJEyypkZNnamhj5HCF7nUuG6XjNKGUiyxsIzqoB3
o3A5hl2P1/t7mqUZBHgpp028BsHmlmY21En9DN0zZGqYI2vwhMWI5F+vaistpj6f
n255Qv/30jWTR3mW3Sni+UiuKy2FzWiTRgC1vSdxyDO64ff8AHLCn3sBZy5fXk//
CmCssV6Mcn7q4k2M1jyPTywRJwV2ovpXrZUtj8oiL8nC2k+Es3eBL4rJESV3t3YH
a+MgKRglIXtCsKSNSBrKJJ8APV1Let00MWVuKWq32Fjrxsk6+cFLn89Vj0ZqIzD8
igxAo76jvrwfPlTxysxlIW5wVVyjkHLRhKZffPoibGLtkr4XDePtUXT9/KKqBh3X
ZMQtTQTCedFtx7hkaL0ULn3hOhKpQ3FRwAHePn1QrzevwhOkES11KPkvtgDc31M5
dgvvX0CiX1i0JguLz0k/UgjgvHjtDghosyvp2yDZ6V5s7Bymzs9ZqmrXHLiohcWS
Ag0Niak2uts=
=zHWQ
-----END PGP SIGNATURE-----

--=-vtRNivqj9iPwhgG5fa5T--
