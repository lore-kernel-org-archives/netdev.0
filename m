From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 9/9] can: pch_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:25:12 +0100
Message-ID: <4D161AE8.1060905@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
	<1293288034-22428-10-git-send-email-mkl@pengutronix.de>
	<4D161334.3090100@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3407694810406692548=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D161334.3090100-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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
--===============3407694810406692548==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3C84FFE95750F9B6E1065456"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3C84FFE95750F9B6E1065456
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/25/2010 04:52 PM, Oliver Hartkopp wrote:
> On 25.12.2010 15:40, Marc Kleine-Budde wrote:
>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Cc: Tomoya <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
>> ---
>>  drivers/net/can/pch_can.c |   15 ++++++++-------
>>  1 files changed, 8 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
>> index c42e972..ee488ac 100644
>> --- a/drivers/net/can/pch_can.c
>> +++ b/drivers/net/can/pch_can.c
>> @@ -692,16 +692,17 @@ static int pch_can_rx_normal(struct net_device *=
ndev, u32 obj_num, int quota)
>>  			cf->can_id =3D id;
>>  		}
>> =20
>> -		if (id2 & PCH_ID2_DIR)
>> -			cf->can_id |=3D CAN_RTR_FLAG;
>> -
>>  		cf->can_dlc =3D get_can_dlc((ioread32(&priv->regs->
>>  						    ifregs[0].mcont)) & 0xF);
>> =20
>> -		for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
>> -			data_reg =3D ioread16(&priv->regs->ifregs[0].data[i / 2]);
>> -			cf->data[i] =3D data_reg;
>> -			cf->data[i + 1] =3D data_reg >> 8;
>> +		if (id2 & PCH_ID2_DIR) {
>> +			cf->can_id |=3D CAN_RTR_FLAG;
>> +
>=20
> } else {

doh! Should not write patches after big xmas lunch.
>=20
> ???
>=20
>> +			for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
>> +				data_reg =3D ioread16(&priv->regs->ifregs[0].data[i / 2]);
>> +				cf->data[i] =3D data_reg;
>> +				cf->data[i + 1] =3D data_reg >> 8;
>> +			}
>>  		}
>> =20
>>  		netif_receive_skb(skb);
>=20
> Regards,
> Oliver

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3C84FFE95750F9B6E1065456
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk0WGuwACgkQjTAFq1RaXHMBigCXTbaosvl2RSa8Al20eh/xYxuu
ZwCfZaaQp0PaJDlMpz2140JHv0BsF2M=
=g4Ge
-----END PGP SIGNATURE-----

--------------enig3C84FFE95750F9B6E1065456--

--===============3407694810406692548==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============3407694810406692548==--
