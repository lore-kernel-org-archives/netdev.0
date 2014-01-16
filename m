From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] net: can: Disable flexcan driver build for big endian
 CPU on ARM
Date: Thu, 16 Jan 2014 17:49:13 +0100
Message-ID: <52D80D89.1040706@pengutronix.de>
References: <3157541.PQSkPAVrH7@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="t2uQI9eqIGN3r3LOR0okSw4W3AEEu4WO4"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <3157541.PQSkPAVrH7@wuerfel>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--t2uQI9eqIGN3r3LOR0okSw4W3AEEu4WO4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/14/2014 11:44 AM, Arnd Bergmann wrote:
>> On 01/06/2014 02:21 PM, Guenter Roeck wrote:
>>> Building arm:allmodconfig fails with
>>>
>>> flexcan.c: In function 'flexcan_read':
>>> flexcan.c:243:2: error: implicit declaration of function 'in_be32'
>>> flexcan.c: In function 'flexcan_write':
>>> flexcan.c:248:2: error: implicit declaration of function 'out_be32'
>>>
>>> in_be32 and out_be32 do not (or no longer) exist for ARM targets.
>>> Disable the build for ARM on big endian CPUs.
>>>
>>> Signed-off-by: Guenter Roeck <linux@xxxxxxxxxxxx>
>>
>> Applied to can-next.
>=20
> Sorry, this patch was wrong.
>=20
> There is no reason to disallow building the driver on big-endian
> ARM kernels. Furthermore, the current behavior is actually broken
> on little-endian PowerPC as well.
> The choice of register accessor functions must purely depend
> on the CPU architecture, not which endianess the CPU is running
> on. Note that we nowadays allow both big-endian ARM and little-endian
> PowerPC kernels.
> With this patch applied, we will do the right thing in all four
> combinations.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks Arnd, I've squashed in the revert of Guenter's patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--t2uQI9eqIGN3r3LOR0okSw4W3AEEu4WO4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLYDYkACgkQjTAFq1RaXHOqygCcCUSmhFR6jI383yeXjJMMWqVu
+FAAn3Ihf3a9iiYYGaXdKZyp2IFuBsGp
=v3uu
-----END PGP SIGNATURE-----

--t2uQI9eqIGN3r3LOR0okSw4W3AEEu4WO4--
