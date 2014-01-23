From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 1/2] can: Decrease default size of CAN_RAW socket send
 queue
Date: Thu, 23 Jan 2014 22:01:37 +0100
Message-ID: <52E18331.6050607@pengutronix.de>
References: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz> <20140123.124108.891860564230946746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="FFxeO8rvE9K4FHuflNcJiO3TPnhscLhUd"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, sojkam1@fel.cvut.cz
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140123.124108.891860564230946746.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FFxeO8rvE9K4FHuflNcJiO3TPnhscLhUd
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/23/2014 09:41 PM, David Miller wrote:
> From: Michal Sojka <sojkam1@fel.cvut.cz>
> Date: Wed, 22 Jan 2014 09:27:36 +0100
>=20
>> Since the length of the qdisc queue was set by default to 10
>> packets, this is exactly what was happening.
>=20
> This is your bug, set the qdisc limit to something more reasonable.
>=20
> Something large enough to absorb the traffic wrt. the speed at which
> the CAN device can sink the data.

Hmmm, the problem is on i686 I have to increase the txqueuelen to 366
before the socket works as expected (writes are blocking). This means if
there are two processes one sending a stream of bulk data and the other
one occasionally more important data there will be a lot of frames in
front of the important ones.

With Michal's patch we can limit the number of frames in flight to a
reasonably low amount.

> These two patches are something I am not willing to apply to my
> tree, this is not how you solve this problem, sorry.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--FFxeO8rvE9K4FHuflNcJiO3TPnhscLhUd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLhgzEACgkQjTAFq1RaXHPTNgCdE6HgiMs467WA5VKtrKZsUmve
VDEAni4N4t2c1CXpNO1HvdQDYNa4dCYV
=g1AI
-----END PGP SIGNATURE-----

--FFxeO8rvE9K4FHuflNcJiO3TPnhscLhUd--
