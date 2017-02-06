From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
Date: Mon, 6 Feb 2017 17:43:43 +0100
Message-ID: <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
 <20170206.111259.2261971436931731059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SoevQEP5Ne5h8vX1cOirNAMCqHIPbJaOc"
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42925 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751909AbdBFQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:43:53 -0500
In-Reply-To: <20170206.111259.2261971436931731059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SoevQEP5Ne5h8vX1cOirNAMCqHIPbJaOc
Content-Type: multipart/mixed; boundary="TAMBqVoPeH9aiFRgce27uNi4eKftKBxtr";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de, linux-can@vger.kernel.org
Message-ID: <809cdb71-a29c-f952-0cab-ff643b4906f0@pengutronix.de>
Subject: Re: pull-request: can-next 2017-02-06,pull-request: can-next
 2017-02-06
References: <2b600a5b-f928-fe73-5b30-8b2fc1398068@pengutronix.de>
 <20170206.111259.2261971436931731059.davem@davemloft.net>
In-Reply-To: <20170206.111259.2261971436931731059.davem@davemloft.net>

--TAMBqVoPeH9aiFRgce27uNi4eKftKBxtr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/06/2017 05:12 PM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Mon, 6 Feb 2017 15:50:48 +0100
>=20
>> this is a pull request of 16 patches for net-next/master.
>>
>> The first two patches by David Jander and me add the rx-offload
>> framework for CAN devices to the kernel. The remaining 14 patches
>> convert the flexcan driver to make use of it.
>=20
> Pulled, but I wonder if your comparisons does the right thing when the
> counters overflow.
>=20
> I think you need to do the same thing we do for TCP sequence number
> comparisons and code it like:
>=20
> static inline bool before(__u32 seq1, __u32 seq2)
> {
>         return (__s32)(seq1-seq2) < 0;
> }

Yes, I think it's basically the same as the TCP sequence number code,
but obviously less readable.

> static int can_rx_offload_compare(struct sk_buff *a, struct sk_buff *b)=

> {
> 	const struct can_rx_offload_cb *cb_a, *cb_b;
>=20
> 	cb_a =3D can_rx_offload_get_cb(a);
> 	cb_b =3D can_rx_offload_get_cb(b);
>=20
> 	/* Substract two u32 and return result as int, to keep
> 	 * difference steady around the u32 overflow.
> 	 */
> 	return cb_b->timestamp - cb_a->timestamp;
> }

This does the "(__s32)(seq1-seq2)"

> 	skb_queue_reverse_walk(head, pos) {
> 		const struct can_rx_offload_cb *cb_pos, *cb_new;
>=20
> 		cb_pos =3D can_rx_offload_get_cb(pos);
> 		cb_new =3D can_rx_offload_get_cb(new);
>=20
> 		netdev_dbg(new->dev,
> 			   "%s: pos=3D0x%08x, new=3D0x%08x, diff=3D%10d, queue_len=3D%d\n",
> 			   __func__,
> 			   cb_pos->timestamp, cb_new->timestamp,
> 			   cb_new->timestamp - cb_pos->timestamp,
> 			   skb_queue_len(head));
>=20
> 		if (compare(pos, new) < 0)

And here the "return ... < 0;"

> 			continue;
> 		insert =3D pos;
> 		break;
> 	}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--TAMBqVoPeH9aiFRgce27uNi4eKftKBxtr--

--SoevQEP5Ne5h8vX1cOirNAMCqHIPbJaOc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAliYp78ACgkQHv7KIOw4
HPbm3ggAjmlkHdNKw1qs/HvsmOwA8M+3Jz5BGogTzu1sNfI2YQRshkuDsO0agMne
SBqjgLpsyzhGOG2/jT31V7Bx7sgtPdsAPrIcejVXbrcDd3lfszOBKPA9FPWjo8LU
EKBRz1nGCOZUeirGitZQu3NYIS/Cd5BWwHo/QK+z45eymlUjsUVOjWvB0EOF1Zip
cP5txZEKi8nuu4ifhL+U6ttKXvCZj2wttA03Q7aFVKFjcQ1+GGA1zB7YWOQM1w3h
aZg9pYG5omi5gKjAnhpp4iakvJNpPyEZwnSs9J63l09gY1p4JZnhqxr5mrEwGP3E
KUse9QnD+t2IwuwMgctGXAXSH6MRUA==
=AhuT
-----END PGP SIGNATURE-----

--SoevQEP5Ne5h8vX1cOirNAMCqHIPbJaOc--
