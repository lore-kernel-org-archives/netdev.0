From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 09 Aug 2011 14:04:34 +0200
Message-ID: <4E412252.5000106@pengutronix.de>
References: <1312869313-22434-1-git-send-email-holt@sgi.com>
	<1312869313-22434-5-git-send-email-holt@sgi.com>
	<20110809063319.GK4926@sgi.com> <4E40DDA5.1050004@grandegger.com>
	<20110809114043.GN4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0821842199079900128=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110809114043.GN4926-sJ/iWh9BUns@public.gmane.org>
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
--===============0821842199079900128==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2361097E0AB76C23223C0B95"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2361097E0AB76C23223C0B95
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/09/2011 01:40 PM, Robin Holt wrote:
> On Tue, Aug 09, 2011 at 09:11:33AM +0200, Wolfgang Grandegger wrote:
>>> +	return &p1010_rdb_system_clock;
>>
>> Just returning fsl_get_sys_freq() here would already be fine. I'm also=

>> missing the factor of two here:
>>
>>         return fsl_get_sys_freq() / 2; ????
>=20
> I am working on the other comments right now as well, but this one
> brought up a good question.  The old algorithm in the original freescal=
e
> patches I started with actually did, essentially:
>=20
> 	...clock.freq =3D DIV_ROUND_CLOSEST(fsl_get_sys_freq() / 2, 1000) * 10=
00
>=20
> The end result was before:
> 	...clock.freq=3D0x0bebc200

That's exactly 200 MHz

> After:
> 	...clock.freq=3D0x0bebc1fe

this is 199 999 998 Hz

> Is that rounding relavent?

_If_ 200 MHz is correct, this would be an error of 0.000001%. But the
fsl code rounds to closest KHz. Rounding introduces errors in most of
the cases. IMHO it's better not to round here.

For example the usual at91can is clocked with 99.532800 MHz, this is a
least the value the arm clock framework reports.

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2361097E0AB76C23223C0B95
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5BIlUACgkQjTAFq1RaXHOnnACfdRP3JrCLPDCqtDxN6P4UUvvM
W4oAn0uKbOHL6PIULb325PuQ19A6VcAN
=nVB5
-----END PGP SIGNATURE-----

--------------enig2361097E0AB76C23223C0B95--

--===============0821842199079900128==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0821842199079900128==--
