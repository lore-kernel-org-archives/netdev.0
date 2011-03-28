From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: poll broken (for can) (was: Re: Multiple programs
 trying to access the socket)
Date: Mon, 28 Mar 2011 18:13:36 +0200
Message-ID: <4D90B3B0.2010401@pengutronix.de>
References: <1301321142.9519.10.camel@lukonin-pc>	<4D90A7E9.1080804@grandegger.com>
	<4D90AA8A.9010804@pengutronix.de> <4D90AF67.1080405@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3494630910939338135=="
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D90AF67.1080405-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============3494630910939338135==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4DD16C90C15C6A941B461915"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4DD16C90C15C6A941B461915
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/28/2011 05:55 PM, Wolfgang Grandegger wrote:
>> BTW: I figured out why poll() wakes you up but the next write will fai=
l
>> with -ENOBUFS again.
>=20
> Ah, I'm curious? I also did realize that poll does burn CPU cycles
> (instead of waiting).

The poll callback checks if the used memory is less than the half of per
socket snd buffer (IIRC ~60K). See:

datagram_poll (http://lxr.linux.no/linux+v2.6.38/net/core/datagram.c#L737=
)
sock_writeable (http://lxr.linux.no/linux+v2.6.38/include/net/sock.h#L161=
8)

Because the size of a can frame (+the skb overhead) is much less then
the ethernet frame (+overhead) the default value for the snd buffer is
too big for can.

We get the -ENOBUF from write() if the tx_queue_len (default 10) is
exceeded.

http://lxr.linux.no/linux+v2.6.38/drivers/net/can/dev.c#L435
http://lxr.linux.no/linux+v2.6.38/net/can/af_can.c#L268

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4DD16C90C15C6A941B461915
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2Qs7AACgkQjTAFq1RaXHMtEACfZNdpx0zruJcGUW9nWqeciymv
BtMAn239SimAeuQ9EorNVvvsMfZ3PQcL
=FJnr
-----END PGP SIGNATURE-----

--------------enig4DD16C90C15C6A941B461915--

--===============3494630910939338135==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============3494630910939338135==--
