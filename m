From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 11:22:12 +0100
Message-ID: <1257762132.29454.161.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>
	 <4AF442C2.9040704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-htVjPM6VYgqlLu4/hR5x"
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51751 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbZKIKWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 05:22:22 -0500
In-Reply-To: <4AF442C2.9040704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-htVjPM6VYgqlLu4/hR5x
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-11-06 at 16:37 +0100, Patrick McHardy wrote:

> >> This seems pretty similar to the NETLINK_URELEASE notifier invoked
> >> in netlink_release(). Wouldn't that one work as well?
> >=20
> > Hmm, it does seem similar, thanks for pointing it out. What exactly doe=
s
> > the condition
> > 	if (nlk->pid && !nlk->subscriptions) {
> >=20
> > mean though?
>=20
> nlk->pid is non-zero for bound sockets, which is basically any
> non-kernel socket which has either sent a message or explicitly
> called bind(). nlk->subscriptions is zero for sockets not bound
> to multicast groups.
>=20
> So effectively it invokes the notifier for all bound unicast
> userspace sockets. Not sure why it doesn't invoke the notifier
> for sockets that are used for both unicast and multicast
> reception. If that is a problem I think the second condition
> could be removed.

Thanks for the explanation. I think we'd need the second condition
removed, I don't see a reason to force a socket to not also have
multicast RX if it's used for any of the purposes we're looking at this
for. Guess we need to audit the callees to determine whether that's ok.

Can you quickly explain the difference between release and destruct?

johannes

--=-htVjPM6VYgqlLu4/hR5x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK9+1OAAoJEODzc/N7+Qma+ygP/1p855p0bRzdOnmbt0yNwAFS
e38shpFXgu++hBEOaZi3gT9nHvWtSU2u+i96py8neAldz+Pe/hJI7kdlbTtRrk34
2oJzcegoai++I5ylhdgzXpQO/2eJlMf2jEuvb6xOzf7/7Sdqze7OyuQUx0Wj6zBS
uqrTVcPpvPIJCPBcxslL9QcSZIYM+Y9uefIW/wxf8Y4DUEvaYx6WUzrDoMmeVAUr
rzYZMnPC5hIzWQgv0OKiQJ8nyJm6KDM5GInzFlLTc9RApKetTYu2SM085XE6tSrl
H4L1Ms94UuvhbVwy3+I88Lev3h119ATrPla+Ef3HyjwDpgqk/7pw6BDH48TDNIuk
BuiwhyKl+KY8JMtIDxCkx5w5H3As6QuDjKEa4oJL2ZEtz/htb1wzSm0lnN6tDBJ9
6msVc6EQsnx/YId0ow7INkAgyzbO2R2aDS/1GdDsn35UUL8zX49iODgpN6Lto82p
PLfqPDTM55B5/OZiC43Pvv8uc6P7vKK9518HHVNhN4RrZNNOsyoXRIBrftSCEzig
NENrnKjrtNdgs51Z+R1KZ0VdDn2K1kFxbIGbRLv/3XnEl6/g89+0scPsGPM1Qn9D
IsJAJhe6Y9hqpCxZPxXZiiIoqq4Cw7GkZcmdWmetjZZJ1WSpGQ/mvuCTRhiAfveN
FxTfp4/1T+rkff3SC/8j
=8igV
-----END PGP SIGNATURE-----

--=-htVjPM6VYgqlLu4/hR5x--

