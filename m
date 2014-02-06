From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 5/5] can: sja1000: of: add reg-io-width property for
 8, 16 and 32-bit register access
Date: Thu, 06 Feb 2014 11:57:46 +0100
Message-ID: <52F36AAA.9000704@pengutronix.de>
References: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch> <1391175277-19833-6-git-send-email-florian.vaussard@epfl.ch> <52EBAE41.8060403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="GXkxwWb545oR4MXOXRBlnhG69k877C0W4"
Cc: Andreas Larsson <andreas@gaisler.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EBAE41.8060403@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GXkxwWb545oR4MXOXRBlnhG69k877C0W4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 03:08 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 31-01-2014 17:34, Florian Vaussard wrote:
>=20
>> Add the 'reg-io-width' property for 8, 16 and 32-bit access, like
>> what is currently done with IORESOURCE_MEM_{8,16,32}BIT for non-OF
>> boot.
>=20
>> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
>> ---
>>   drivers/net/can/sja1000/sja1000_platform.c | 16 ++++++++++++++--
>>   1 file changed, 14 insertions(+), 2 deletions(-)
>=20
>> diff --git a/drivers/net/can/sja1000/sja1000_platform.c
>> b/drivers/net/can/sja1000/sja1000_platform.c
>> index 50dece8..25122bf 100644
>> --- a/drivers/net/can/sja1000/sja1000_platform.c
>> +++ b/drivers/net/can/sja1000/sja1000_platform.c
>> @@ -102,8 +102,20 @@ static void sp_populate_of(struct sja1000_priv
>> *priv, struct device_node *of)
>>       int err;
>>       u32 prop;
>>
>> -    priv->read_reg =3D sp_read_reg8;
>> -    priv->write_reg =3D sp_write_reg8;
>> +    err =3D of_property_read_u32(of, "reg-io-width", &prop);
>> +    if (err)
>> +        prop =3D 1;
>> +
>> +    if (prop =3D=3D 4) {
>=20
>    This is asking to be a *switch* statement instead.

Good point, I'll send a v4.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--GXkxwWb545oR4MXOXRBlnhG69k877C0W4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLzaqoACgkQjTAFq1RaXHNO1gCfb/yEcJjJwDr+JfgsIbzd+1rA
VXYAn10t+Ad+bq+d3MJuAwxFoiciVpSK
=bbVC
-----END PGP SIGNATURE-----

--GXkxwWb545oR4MXOXRBlnhG69k877C0W4--
