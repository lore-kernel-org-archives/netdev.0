From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Thu, 03 Nov 2011 10:59:23 +0100
Message-ID: <4EB265FB.7060603@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA8E0@exch01-aklnz.MARINE.NET.INT> <1320313675-30749-1-git-send-email-mkl@pengutronix.de> <1320313675-30749-3-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA209C2F11E106D4B6320F9DE"
Cc: socketcan@hartkopp.net, kurt.van.dijck@eia.be,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben.Dowle@navico.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34634 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206Ab1KCJ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 05:59:28 -0400
In-Reply-To: <1320313675-30749-3-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA209C2F11E106D4B6320F9DE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/03/2011 10:47 AM, Marc Kleine-Budde wrote:
> From: Reuben Dowle <Reuben.Dowle@navico.com>
>=20
> Currently the flexcan driver uses hardware local echo. This blindly
> echos all transmitted frames to all receiving sockets, regardless what
> CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.
>=20
> This patch now submits transmitted frames to be echoed in the transmit
> complete interrupt, preserving the reference to the sending
> socket. This allows the can protocol to correctly handle the local
> echo.
>=20
> Further this patch moves tx_bytes statistic accounting into the tx_comp=
lete
> handler.
>=20
> Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>
> [mkl: move tx_bytes accounting into tx_complete handler; cleanups]
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---

A changelog would be nice :)

Since v1 (Reuben's original version):
- wrap patch description to 80 lines
- remove can_free_echo_skb() from flexcan_chip_start()
  not needed as Reuben pointed out
- remove comments about IFF_ECHO; see patch description for this
- closed potential race condition in flexcan_start_xmit()
  first call can_put_echo_skb(), then trigger xmit
- moved tx_bytes accounting to tx_complete handler;
  make use of new can_get_echo_skb()

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA209C2F11E106D4B6320F9DE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6yZf4ACgkQjTAFq1RaXHOA2gCfQwtE/KbsGvJntuEH1QA+G16Q
ycEAn3Lya6HHVbDOSwbXdj5x8HAf+08Q
=LNhV
-----END PGP SIGNATURE-----

--------------enigA209C2F11E106D4B6320F9DE--
