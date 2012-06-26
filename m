From: Phil Dibowitz <phil@ipom.com>
Subject: Re: [PATCH] Allow receiving packets on the fallback tunnel if they
 pass sanity checks
Date: Mon, 25 Jun 2012 20:37:35 -0700
Message-ID: <4FE92E7F.5040803@ipom.com>
References: <20120605154058.GA16615@ipom.com> <20120620.210405.2231549940491911080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA5A5B69102AAF13A2A546F08"
Cc: netdev@vger.kernel.org, phild@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ipom.com ([96.126.97.66]:35977 "EHLO mail.ipom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756237Ab2FZDhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 23:37:43 -0400
In-Reply-To: <20120620.210405.2231549940491911080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA5A5B69102AAF13A2A546F08
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/20/2012 09:04 PM, David Miller wrote:
> From: Phil Dibowitz <phil@ipom.com>
> Date: Tue, 5 Jun 2012 08:40:58 -0700
>=20
>> From b413062771afbba064ae9bc49b5daed7abb1243d Mon Sep 17 00:00:00 2001=

>> From: Ville Nuorvala <ville.nuorvala@gmail.com>
>> Subject: [PATCH] Allow receiving packets on the fallback tunnel if the=
y pass sanity checks
>>
>> The same IPv6 address checks are performed as with any normal tunnel,
>> but as the fallback tunnel endpoint addresses are unspecified, the che=
cks
>> must be performed on a per-packet basis, rather than at tunnel
>> configuration time.
>>
>> Signed-off-by: Ville Nuorvala <ville.nuorvala@gmail.com>
>> Tested-by: Phil Dibowitz <phil@ipom.com>
>=20
> I've reviewed this change but I still have no idea why it's
> necessary.
>=20
> You need to compose a more lengthy and detailed commit log message
> explaining everything before I'm going to consider applying this
> patch.
>=20
> You can't just say "we have some problem at Facebook, this patch fixes
> it", and then merely describe word by word the content of the patch
> without explaining the "why".  That simply doesn't cut it.

Sure. Sorry, I just kept Ville's patch description.

We do Layer-3 DSR via IP-in-IP tunneling. Our load balancers wrap an extr=
a IP
header on incoming packets so they can be routed to the backend. In the v=
4
tunnel driver, when these packets fall on the default tunl0 device, the
behavior is to decapsulate them and drop them back on the stack. So our s=
etup
is that tunl0 has the VIP and eth0 has (obviously) the backend's real add=
ress.

In IPv6 we do the same thing, but the v6 tunnel driver didn't have this s=
ame
behavior - if you didn't have an explicit tunnel setup, it would drop the=
 packet.

This patch brings that v4 feature to the v6 driver.

I think that's the level of detail you're looking for, but I'm happy to e=
xpand
on anything in particular. I also break this down in tons of detail here:=


https://www.facebook.com/notes/facebook-engineering/under-the-hood-networ=
k-implementation-for-world-ipv6-launch/10150873176303920

--=20
Phil Dibowitz                             phil@ipom.com
Open Source software and tech docs        Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"Be who you are and say what you feel, because those who mind don't matte=
r
 and those who matter don't mind."
 - Dr. Seuss



--------------enigA5A5B69102AAF13A2A546F08
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/pLn8ACgkQN5XoxaHnMrvbrwCeLXaEeZA9TSn7AVuLsee2vWHq
4bIAn0Qx9gWUrq/HPXsdJI0TYgZqG5Dp
=t5xG
-----END PGP SIGNATURE-----

--------------enigA5A5B69102AAF13A2A546F08--
