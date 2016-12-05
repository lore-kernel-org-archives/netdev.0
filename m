From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
Date: Mon, 5 Dec 2016 11:55:45 +0100
Message-ID: <1d643f72-d90a-ab39-a23c-844766c10749@pengutronix.de>
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
 <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
 <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
 <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
 <6fe05efd-eb2c-a5e2-9d45-48f2c3098abb@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lpn3P6fO2KhAuQvsCO2IPwVO5LjnXiJvV"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <6fe05efd-eb2c-a5e2-9d45-48f2c3098abb@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lpn3P6fO2KhAuQvsCO2IPwVO5LjnXiJvV
Content-Type: multipart/mixed; boundary="qBikJLJmAmUdFF4KjOcAvTKTSVRtE7FBk";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
 Andrey Konovalov <andreyknvl@google.com>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 syzkaller <syzkaller@googlegroups.com>
Message-ID: <1d643f72-d90a-ab39-a23c-844766c10749@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
 <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
 <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
 <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
 <6fe05efd-eb2c-a5e2-9d45-48f2c3098abb@hartkopp.net>
In-Reply-To: <6fe05efd-eb2c-a5e2-9d45-48f2c3098abb@hartkopp.net>

--qBikJLJmAmUdFF4KjOcAvTKTSVRtE7FBk
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/02/2016 06:05 PM, Oliver Hartkopp wrote:
>=20
>=20
> On 12/02/2016 04:42 PM, Marc Kleine-Budde wrote:
>> On 12/02/2016 04:11 PM, Oliver Hartkopp wrote:
>>>
>>>
>>> On 12/02/2016 02:24 PM, Marc Kleine-Budde wrote:
>>>> On 12/02/2016 01:43 PM, Andrey Konovalov wrote:
>>>
>>>
>>>>>  [<ffffffff8369e0de>] raw_setsockopt+0x1be/0x9f0 net/can/raw.c:506
>>>>
>>>> We should add a check for a sensible optlen....
>>>>
>>>>> static int raw_setsockopt(struct socket *sock, int level, int optna=
me,
>>>>> 			  char __user *optval, unsigned int optlen)
>>>>> {
>>>>> 	struct sock *sk =3D sock->sk;
>>>>> 	struct raw_sock *ro =3D raw_sk(sk);
>>>>> 	struct can_filter *filter =3D NULL;  /* dyn. alloc'ed filters */
>>>>> 	struct can_filter sfilter;         /* single filter */
>>>>> 	struct net_device *dev =3D NULL;
>>>>> 	can_err_mask_t err_mask =3D 0;
>>>>> 	int count =3D 0;
>>>>> 	int err =3D 0;
>>>>>
>>>>> 	if (level !=3D SOL_CAN_RAW)
>>>>> 		return -EINVAL;
>>>>>
>>>>> 	switch (optname) {
>>>>>
>>>>> 	case CAN_RAW_FILTER:
>>>>> 		if (optlen % sizeof(struct can_filter) !=3D 0)
>>>>> 			return -EINVAL;
>>>>
>>>> here...
>>>>
>>>> 		if (optlen > 64 * sizeof(struct can_filter))
>>>> 			return -EINVAL;
>>>>
>>>
>>> Agreed.
>>>
>>> But what is sensible here?
>>> 64 filters is way to small IMO.
>>>
>>> When thinking about picking a bunch of single CAN IDs I would tend to=

>>> something like 512 filters.
>>
>> Ok - 64 was just an arbitrary chosen value for demonstration purposes =
:)
>>
>=20
> :-)
>=20
> Would you like to send a patch?

Yes, how many Filters? 512? Can you test, as I don't have the setup ready=
?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qBikJLJmAmUdFF4KjOcAvTKTSVRtE7FBk--

--lpn3P6fO2KhAuQvsCO2IPwVO5LjnXiJvV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhFR7EACgkQPTuqJayp
JWq8dQf+PDkoyNL5m6WBE76ojPnKNkhSS8gNvxysN0zCLe+xv52A1pAxVF0jIuFq
NbF3vyXkNrX0UwSHWS/p76o4noan+49h+XFWmsGFckdrX+94lGahEIWqSpPklbAm
hUnsU3uIvpgV9cn7CstMAx/68KSAo9Ffq82bfk84ALU+KqB0vBTgRjQQFU5fYfqs
HCcI1AmHSWYg/jBPKsJA5jlgIn6e+KfH78yWKLFfpyDcBojkux2K91Pn76kTkdpN
JHnPf4iqZU/pmqF95U7GcEt8RK0I7m3dLx6k1cQRscN7JCJX3XPZeeHFrZQ1aNhQ
2X2/je0q4kg3UB0+vMfDnCtv9MBxGQ==
=OECu
-----END PGP SIGNATURE-----

--lpn3P6fO2KhAuQvsCO2IPwVO5LjnXiJvV--
