From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Mon, 05 Jan 2009 09:36:14 +0100
Message-ID: <1231144574.3286.15.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 <1231085150.3296.3.camel@johannes>
	 <20090104162826.GT496@one.firstfloor.org>
	 <1231087288.3296.15.camel@johannes>
	 <20090104174339.GX496@one.firstfloor.org>
	 <1231090388.3296.17.camel@johannes>
	 <20090104184136.GY496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XG+m6QfDIuW39io5uPJL"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, davem <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:48570 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbZAEIfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 03:35:33 -0500
In-Reply-To: <20090104184136.GY496@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XG+m6QfDIuW39io5uPJL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-01-04 at 19:41 +0100, Andi Kleen wrote:

> I think most adjustments are too small to be noticed. Typically
> they are just for a few bytes in the header. truesize
> is already larger, so it can tolerate some slag.

This statement is incompatible with your patch when you think about the
exact definition of truesize and the (unconditional!) adjustments your
patch makes.

> I also only see it occasionally (maybe 5-10 times/day) when
> the wireless stack appends a lot of data.

Except the data it appends should generally be of the same or very
similar size under unchanging conditions, so that doesn't make a lot of
sense either.

> My proposal would be to include this patch for 2.6.28/2.6.29
> and investigate fixing pskb_expand_head for 2.6.30.

I disagree, obviously. I knew there was some truesize corruption, and I
think you for tracing down where it occurs. I'll investigate a proper
fix when I get around to that, meanwhile I don't think the problem is
awfully urgent since we've had this going on for quite a while and, if
any, it probably only affects/corrupts the raw monitor sockets.

johannes

--=-XG+m6QfDIuW39io5uPJL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYcZ7AAoJEKVg1VMiehFYmHMP/RhvtkeYWZgv/mctgmTsxrbN
GaFyHsExlrB/2JvpHJRCZy61jmHRG9b3YWfO8ZI9W4mR9a0WO3/8cT2YGp2H3+6Y
upO+V9N8KUTcuqtvRFnYW0jcEmyCL7PqE8haYAklYVYwarbhGt9llugznqJlLtql
o2j+aLRVSSvjs11M2KhDGcUTeQtZ9Xw6nygJSAs2KMf3pFwIgdmC8uFh/4Mrt8C7
wFb//nJyBzmA/GYdesOk44/dJUwoLiUCueN9hqflSAEmRgUU3aQJBSZp4dqZhsBx
fsM0OXOl4KWgjMSQmb5KS/NBMGh0DkEUV9WZawAK3EnSv+c/6orQluJ+78/FdgwU
Ov3ASZV3QxTGWOmWcQ7JlzPOXW8LRxtRaYS9Aq31hGyymKdpBNBrFp1TKsPczGuz
G51m23McWRRIn0bcWKTzHzhGBc1XZbco60nLlFuTwC5tsLAdv9hj9IJcZNVs5ufQ
d1cyeTswDTAUPEPWn+2Tkg3+KxEE6FEel2MZnD38vagqLiIwipvr/4ENkGc4WkT7
BiwcKooBmQwzqp7Las1v5PIJvShB5mFjdXd6sYminauZAEonHzmqH4gj0Uj/40KZ
TJuRwGTlJZFeq+shbEKYhuWw5zsfKQ2hdSO7idY48xIaNp2gNU4yUaXAceT0VcCi
pBN1Y3c7D/UTco7Zab9a
=GmMd
-----END PGP SIGNATURE-----

--=-XG+m6QfDIuW39io5uPJL--

