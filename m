From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Thu, 15 Jul 2010 12:06:41 +0200
Message-ID: <4C3EDDB1.5040109@pengutronix.de>
References: <1279144811-12251-1-git-send-email-mkl@pengutronix.de>
	<4C3ED6F5.7040606@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3085278365651692246=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C3ED6F5.7040606-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============3085278365651692246==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB303FDF1CB769B8CA7AC1B46"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB303FDF1CB769B8CA7AC1B46
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hey Wolfgang,

Wolfgang Grandegger wrote:
>> This core is found on some Freescale SoCs and also some Coldfire
>> SoCs. Support for Coldfire is missing though at the moment as
>> they have an older revision of the core which does not have RX FIFO
>> support.
>>
>> Signed-off-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> ---
>>
>> Changes to prev version:
>> * The is now GPLv2 (only) as no one complained.
>>
>> The patch applies to current net-next-2.6/master.
>> If there aren't any objections please consider applying this patch.
>> Wolfgang, can I an Acked-by?
>=20
> I already had a look to the previous version and I realized that
> accessing reg_esr is racy. I will dig out my notes and come up with a
> full review later today or tomorrow.

Let me have a look....

I think I should remove the read reg_esr in "flexcan_irq_err()" and use
the value read in "flexcan_irq()"

Without the fix, there's a race window that we loose some error bits
from the interrupt handler to the napi function, because the error bits
are cleared on read.

Regarding the upcoming improvement of the can error frames upon state
changes, I'd first like to get this driver merged and then discuss a
solution for the error frames.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB303FDF1CB769B8CA7AC1B46
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkw+3bEACgkQjTAFq1RaXHOIjgCgiXko1bNigoyf3/Exq5yy/I/Y
xNgAoJfyzfre0zYb800DczT7+AmRreyb
=ZHYj
-----END PGP SIGNATURE-----

--------------enigB303FDF1CB769B8CA7AC1B46--

--===============3085278365651692246==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3085278365651692246==--
