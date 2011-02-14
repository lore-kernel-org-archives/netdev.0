From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Mon, 14 Feb 2011 14:33:17 +0100
Message-ID: <4D592F1D.8010600@pengutronix.de>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
	<20110211150602.GB373@e-circ.dyndns.org>
	<C1C4300CE90A406FBDA2388D5491FAD5@subhasishg>
	<4D58D854.5090503@grandegger.com>
	<1F33D30F9B2D47ECA80CEC807A6C0727@subhasishg>
	<4D58F77B.9080005@pengutronix.de>
	<8CB9F2C8F75C4041B9F0691D209DDAFD@subhasishg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3572979932771043864=="
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	CAN NETWORK DRIVERS <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8CB9F2C8F75C4041B9F0691D209DDAFD@subhasishg>
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
--===============3572979932771043864==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2046FF26DD12E62AC5A72A40"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2046FF26DD12E62AC5A72A40
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/14/2011 02:15 PM, Subhasish Ghosh wrote:
> Hello,
>=20
> The problem with the "all" implementation is that it hogs the ARM/DSP
> heavily and that's the reason why we specifically avoided this in our
> firmware design.
> Hence, implementing this condition spoils the whole purpose of the PRU!=
!

What about implementing the standard id/mask approach?

if (canid & mask =3D=3D id & mask)
	aceept();
else
	discard();

To keep the hot-path as small as possible, the id & mask operation is
done during setup, only one. This is probably just an additional "and"
operation (the "& mask"). This opens the way to act like a normal can
controller.

As long as we don't have any support for hardware filters in socketcan,
it's a good choice to use sysfs to configure your filters.

Have a look at [1] and [2] for how to use sysfs files.

cheers, Marc

[1]
http://git.kernel.org/linus/3a5655a5b545e9647c3437473ee3d815fe1b9050

[2]
http://git.kernel.org/linus/fef52b0171dfd7dd9b85c9cc201bd433b42a8ded

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2046FF26DD12E62AC5A72A40
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1ZLyEACgkQjTAFq1RaXHNkigCfcM+gy4Z69Tk0dOfVUekPjard
y2sAniiFyF+GZcFtuJQ2ShzdYCnW3mZf
=HPax
-----END PGP SIGNATURE-----

--------------enig2046FF26DD12E62AC5A72A40--

--===============3572979932771043864==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3572979932771043864==--
