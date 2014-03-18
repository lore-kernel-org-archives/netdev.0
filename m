From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 03/12] can: c_can: Make it SMP safe
Date: Tue, 18 Mar 2014 19:46:23 +0100
Message-ID: <5328947F.7070902@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171126.844179673@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="K2uvFKNjlNf1dOAWOnSaqPPwuQrgXHlnl"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140318171126.844179673@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--K2uvFKNjlNf1dOAWOnSaqPPwuQrgXHlnl
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/18/2014 06:19 PM, Thomas Gleixner wrote:
> The hardware has two message control interfaces, but the code only
> uses the first one. So on SMP the following can be observed:
>=20
> CPU0 	       	CPU1
> rx_poll()
>   write IF1	xmit()
> 		write IF1
>   write IF1		=09
>=20
> That results in corrupted message object configurations. The TX/RX is
> not globally serialized it's only serialized on a core.
>=20
> Simple solution: Let RX use IF1 and TX use IF2 and all is good.

Do both c_can and d_can have two control interfaces?

> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Otherwise, looks good.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--K2uvFKNjlNf1dOAWOnSaqPPwuQrgXHlnl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMolH8ACgkQjTAFq1RaXHN5MQCbBmucP8ZFcoGpKLXMm9Ixz/VN
XGUAn0+IclBW2Mm1OvR74E3ysPOGX4I0
=k3+W
-----END PGP SIGNATURE-----

--K2uvFKNjlNf1dOAWOnSaqPPwuQrgXHlnl--
