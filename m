From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 10:39:38 +0400
Message-ID: <1116571178.21310.124.camel@uganda>
References: <20050518222729.007887b8.akpm@osdl.org>
	 <1116484313.21310.78.camel@uganda> <20050518234552.4aef6d02.akpm@osdl.org>
	 <20050519.114425.18307286.davem@davemloft.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3vrfiseHvipfAvNB+2o2"
Cc: akpm@osdl.org, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.114425.18307286.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-3vrfiseHvipfAvNB+2o2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-05-19 at 11:44 -0700, David S. Miller wrote:
> From: Andrew Morton <akpm@osdl.org>
> Date: Wed, 18 May 2005 23:45:52 -0700
>=20
> > > Should I ask David Miller to allocate new one specially for connector=
?
> >=20
> > Dave?
>=20
> Giving the connector a single value 10 is OK, the rest of
> what the connector is doing in this area is not.
>=20
> I wish you hadn't put the connector into -mm, it's really
> in need of several fixups still.  The bogus reuse of the
> ULOG netlink number is simply indicative of that.

And how does it indicate that it is bogus? :)
It is one netlink user that can use any socket number - and now
it is called bogus.

What other people suggest is just create some wrapper over=20
netlink_broadcast() and alloc_skb().
if you do think it will solve all problems, then I even will not
say anything. Point.
I just want to note, that if you want message bus, you require
at least oppsite direction, and thus input callback, and
either several socket number for each user [kobject, audit, iscsi,=20
xfrm - all they implement what connector already does] or
some header and thus parser in input callback, and thus
some registration mechanism. Magically it is what connector does.
And nothing more, btw.
It only allows not to rewrite the whole driver just to move
to new transport layer, only register new cn_dev device
with different method.

Ok, Dave, we all see your point, feel free to remove connector,
I will not bother people to include it yet another time...
But I believe in a month or two someone will reinvent the wheel
and create somthing similar. If it will be simple wrapper, then
it just can not solve message bus problem, only notification,=20
and thus someone will create it again.

Thank you.

P.S. smtp server from my old university years seems to still drop
your messages, sorry for that, I will kick admins again.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-3vrfiseHvipfAvNB+2o2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjYYqIKTPhE+8wY0RAo4WAJsG9qiUU1EbgY+i2svMbZRr4BPgCACeP2oC
S2E4iWmI0w8jNtZH2YIeyBA=
=ytJR
-----END PGP SIGNATURE-----

--=-3vrfiseHvipfAvNB+2o2--
