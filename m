From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Thu, 11 Sep 2008 01:57:33 +0200
Message-ID: <1221091053.3804.53.camel@johannes.berg>
References: <1221081539.3804.33.camel@johannes.berg>
	 <20080910.164009.92497081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zIOdv2IOZ8UguoN4lZuP"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49927 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbYIJX6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:58:12 -0400
In-Reply-To: <20080910.164009.92497081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zIOdv2IOZ8UguoN4lZuP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-09-10 at 16:40 -0700, David Miller wrote:

> This is yet another side effect of how ipv6 handles ICMP routes
> seperately from "real" ipv6 routes.

I have no idea :) I just had never seen this on a wired interface and
wanted to see if it was mac80211's fault although I couldn't see how it
could have been.

> Anyways, what happens is that when a device goes down a notifier
> goes out, and in IPV6's case it has a notifier registered in
> net/ipv6/addrconf.c that ends up calling rt6_ifdown() on
> the device.
>=20
> This is supposed to purge routes from the tree so that the device
> references can be dropped (eventually).
>=20
> This is done in ipv6 by fib6_clean_all() but that only handles
> normal routes.  The seperate ICMP6 routes are not purged properly
> in this situation.

And then they time out after 30 seconds? I see the message exactly three
times and then it gets removed.

> Here is a quick patch that might resolve this specific situation.
> Let me know how it works for you:

I'll add it to my tree, but I cannot reproduce the issue at will. It
just happens occasionally when I'm developing.

johannes

--=-zIOdv2IOZ8UguoN4lZuP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIyF7pAAoJEKVg1VMiehFYsSAQAK/yMf4fwJV6I41F3oZD95d1
FYha2wks/a3ACbwUiHzZB0uYgkBNO9dQxHB1wlNTjm11SVn8oR/jsu9ttc0c0Rm9
txlQFaPebpmx93no/tV1tfWoa7AHgyeUOectAmVP/r+xOdz10ic/7lO70IyoZKIz
1djdw+ZGg3sUORFAcqovuERtzAfIlzMxa4+CXdY3dZxC+BTgL/I5G31Ilrd5GLYc
DgK6Tr1vQtdKla/j344HkwdiGd2WUiltC2xf7rWrjbSeVgtC6+CvFn9qp638C9g1
vGLgbSHJF/7merLiTSxICS5VqANUHMXuO5Wnt3AP4SJE/xJSt3/p8hunIJ+mJNnf
DotWMTZkTof6OCsS+2/TC45oV0iQvJmZEn3tzdlyfbLH+9SE1Lbui2yWImHg+l9j
zQMN6zqXVP7xqv2/XH1lAjaftTmGuknbgrq8lj8z9khGfly97ZQ9fT+BmhYa22ZR
jQ4jB3pm3jopYfzocaEtXKosDejeRNC3ZCqMIsJWfJx9Eal84iR5habYuHKdKrdT
FM2kz3ekESevauL7rswqNi9NqvmlNrOHIOxLKHxDpJYywqpeMBpBmtOopSCHdW/r
696fIDlgvYMZv9KijgQt/NU+NmETx9hy9cSaJhd6tv2WLr8fW64CZob1F2qIXeW6
SWNVhd6xGvtlFL41PC5m
=3+Tx
-----END PGP SIGNATURE-----

--=-zIOdv2IOZ8UguoN4lZuP--

