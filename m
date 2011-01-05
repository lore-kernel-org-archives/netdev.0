From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: at91_can: errata "Contents of Mailbox 0 can be sent"
Date: Thu, 06 Jan 2011 00:41:05 +0100
Message-ID: <4D250191.80600@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8030733073188025181=="
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8030733073188025181==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFBA96F7FA04371C8BB3E4630"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFBA96F7FA04371C8BB3E4630
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Moin,

the at91_can core has the following problem:
"50.3.5.3 CAN: Contents of Mailbox 0 can be sent Even if Mailbox is
Disabled"

This means under high bus load it can happen that the mailbox 0 is send
to the bus. And it does happen, even with the mainline driver where
Mailbox 0 is a receive mailbox. The errata proposes not to use mailbox 0
and load it with a unused can_id that will not disturb the bus.

I'm going to implement the workaround. As the unused identifier is
probably application specific my question is: What's the best way to
configure this identifier?

- sysfs
- netlink
- ioctl
- ethtool
- peek/poke :P

What will be a good default can_id?

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigFBA96F7FA04371C8BB3E4630
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0lAZUACgkQjTAFq1RaXHOd/wCdEdn2cHpUqXfkiZ299wBjXB4l
B3sAnRSrjbYZuM9KE4VJ17ZO9NQeUekN
=BYrn
-----END PGP SIGNATURE-----

--------------enigFBA96F7FA04371C8BB3E4630--

--===============8030733073188025181==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8030733073188025181==--
