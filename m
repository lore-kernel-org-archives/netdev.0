From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06,Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
Date: Thu, 9 Feb 2017 10:52:23 +0100
Message-ID: <44f94eb3-4c58-a63f-c7a9-46615155d7b5@pengutronix.de>
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
 <20170206.111259.2261971436931731059.davem@davemloft.net>
 <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
 <20170206.115910.1398846154082627685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HgPKxdbpPcFVlLhER7nAnIgfpHqRwWAbF"
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170206.115910.1398846154082627685.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HgPKxdbpPcFVlLhER7nAnIgfpHqRwWAbF
Content-Type: multipart/mixed; boundary="qmdSTajE2r9vfSe13XfSnXGP2RjHtcRL8";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de, linux-can@vger.kernel.org
Message-ID: <44f94eb3-4c58-a63f-c7a9-46615155d7b5@pengutronix.de>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06,Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
 <20170206.111259.2261971436931731059.davem@davemloft.net>
 <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
 <20170206.115910.1398846154082627685.davem@davemloft.net>
In-Reply-To: <20170206.115910.1398846154082627685.davem@davemloft.net>

--qmdSTajE2r9vfSe13XfSnXGP2RjHtcRL8
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/06/2017 05:59 PM, David Miller wrote:
> Sure but what about these "can_rx_offload_le()" comparisons?

This is to scan the mailboxes according to priority. On some CAN IP
cores the mailboxes decrease in priority (0=3Dhigh, 63=3Dlow) some increa=
se
(63=3Dhigh, 0=3Dlow). The can_rx_offload_le() (le means less or equal) an=
d
can_rx_offload_inc() functions are used to abstract the order. We always
only scan from highest to lower prio (offload->mb_first ...
offload->mb_last):

> 	for (i =3D offload->mb_first;
> 	     can_rx_offload_le(offload, i, offload->mb_last);
> 	     can_rx_offload_inc(offload, &i)) {

So we never wrap around.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qmdSTajE2r9vfSe13XfSnXGP2RjHtcRL8--

--HgPKxdbpPcFVlLhER7nAnIgfpHqRwWAbF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlicO9cACgkQHv7KIOw4
HPZxCwf/URtTJrAEbNoK4Eoi2QWVb9Onns5bbb5D4DaKcaxHZEVp5pNzDPV0R8+Q
YqofxyHX09VLKU1BS1IAbjKAmiO36L4WQ0OXSiV2gcETkutfx8zErTxUImzq3Gzy
Ww71xbrOj5WyYNJjxRAiZSm/X0iZOlfGev/fpuMUZi0X7a6/IX/OXd39hGBGfjAh
bjfMLhaGVLukjmah4d95J22kHhUy1vgnynPoiOM30N6Zd1Ld8MpYEXleuWtQupep
A92SHiM3veY2Vp9OA82ZHctKgDzyZBxhDZoeimSNA4cKyeuWd8uLbMtEwy/PaQkV
ua4ul4qwxZDzUYr3Sz1FyRM5NGexQg==
=TRPC
-----END PGP SIGNATURE-----

--HgPKxdbpPcFVlLhER7nAnIgfpHqRwWAbF--
