From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
Date: Fri, 2 Dec 2016 16:42:35 +0100
Message-ID: <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
 <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
 <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fbDiOlLmK9bFXkOqmbDwQd9sBxgJEE8UN"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37963 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751451AbcLBPnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:43:51 -0500
In-Reply-To: <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fbDiOlLmK9bFXkOqmbDwQd9sBxgJEE8UN
Content-Type: multipart/mixed; boundary="0evitv4CQC3o1naBa1Hlp0cCapjAh1iWG";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
 Andrey Konovalov <andreyknvl@google.com>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 syzkaller <syzkaller@googlegroups.com>
Message-ID: <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
 <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
 <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
In-Reply-To: <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>

--0evitv4CQC3o1naBa1Hlp0cCapjAh1iWG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/02/2016 04:11 PM, Oliver Hartkopp wrote:
>=20
>=20
> On 12/02/2016 02:24 PM, Marc Kleine-Budde wrote:
>> On 12/02/2016 01:43 PM, Andrey Konovalov wrote:
>=20
>=20
>>>  [<ffffffff8369e0de>] raw_setsockopt+0x1be/0x9f0 net/can/raw.c:506
>>
>> We should add a check for a sensible optlen....
>>
>>> static int raw_setsockopt(struct socket *sock, int level, int optname=
,
>>> 			  char __user *optval, unsigned int optlen)
>>> {
>>> 	struct sock *sk =3D sock->sk;
>>> 	struct raw_sock *ro =3D raw_sk(sk);
>>> 	struct can_filter *filter =3D NULL;  /* dyn. alloc'ed filters */
>>> 	struct can_filter sfilter;         /* single filter */
>>> 	struct net_device *dev =3D NULL;
>>> 	can_err_mask_t err_mask =3D 0;
>>> 	int count =3D 0;
>>> 	int err =3D 0;
>>>
>>> 	if (level !=3D SOL_CAN_RAW)
>>> 		return -EINVAL;
>>>
>>> 	switch (optname) {
>>>
>>> 	case CAN_RAW_FILTER:
>>> 		if (optlen % sizeof(struct can_filter) !=3D 0)
>>> 			return -EINVAL;
>>
>> here...
>>
>> 		if (optlen > 64 * sizeof(struct can_filter))
>> 			return -EINVAL;
>>
>=20
> Agreed.
>=20
> But what is sensible here?
> 64 filters is way to small IMO.
>=20
> When thinking about picking a bunch of single CAN IDs I would tend to=20
> something like 512 filters.

Ok - 64 was just an arbitrary chosen value for demonstration purposes :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0evitv4CQC3o1naBa1Hlp0cCapjAh1iWG--

--fbDiOlLmK9bFXkOqmbDwQd9sBxgJEE8UN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhBlmsACgkQPTuqJayp
JWrheQf/WNnQBkM+uerjT6KrO56Ilv8clEOpnFzBEfiUQpoVuPNUAu+3TjkSCqV5
Y91wYd1dnXjLpO+ROKBoy8RwhDCNKnds89Adz/JBSyRvAAl/q3EBZTXS1rBH4obr
sCy/MspEL0nJ9BFj94Bi7UjF21h7SinwKRpTef0NvdwxtpydXIFuZssnEh/sYTV5
ZRqqKm+HaneZwJ0o/PlbSwiAKn1NdKIrt5wo2OYiE9vj5xL30V0tKCSnxdYpCIrj
v7Mo9MSfzNbNRvqNOGVfqagHCNuN0ZgwZm+QbkDnFRJwfVLjTeSEIjbmceByfda/
x12vRpep+3aUbw8fSsK9kX+dyWeWag==
=jTng
-----END PGP SIGNATURE-----

--fbDiOlLmK9bFXkOqmbDwQd9sBxgJEE8UN--
