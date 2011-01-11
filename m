From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 3/3] can: at91_can: make can_id of mailbox 0 configurable
Date: Tue, 11 Jan 2011 12:56:54 +0100
Message-ID: <4D2C4586.60207@pengutronix.de>
References: <1294741688-22699-1-git-send-email-mkl@pengutronix.de>
	<1294741688-22699-4-git-send-email-mkl@pengutronix.de>
	<4D2C42F0.5080703@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6357765106408314792=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2C42F0.5080703-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============6357765106408314792==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig184E52346692D505E3A2CC7F"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig184E52346692D505E3A2CC7F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2011 12:45 PM, Wolfgang Grandegger wrote:
> On 01/11/2011 11:28 AM, Marc Kleine-Budde wrote:
>> Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
>> "AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailb=
ox
>> 0 may be send under certain conditions (even if disabled or in rx mode=
).
>>
>> The workaround in the errata suggests not to use the mailbox and load =
it
>> with a unused identifier.
>>
>> This patch implements the second part of the workaround. A sysfs entry=

>> "mb0_id" is introduced. While the interface is down it can be used to
>> configure the can_id of mailbox 0. The default value id 0x7ff.
>>
>> In order to use an extended can_id add the CAN_EFF_FLAG (0x80000000U)
>> to the can_id. Example:
>>
>> - standard id 0x7ff:
>> echo 0x7ff      > /sys/class/net/can0/mb0_id
>>
>> - extended if 0x1fffffff:
              ^^
I've fixed the typo on my git repo. I'll send an updated series later.

>> echo 0x9fffffff > /sys/class/net/can0/mb0_id
>=20
> As this is a device specific property, I think it should go into
> /sys/class/net/can0/device/.

The attribute goes autoamtically to /sys/class/net/can0 if you add it to
the driver via:

+       dev->sysfs_groups[0] =3D &at91_sysfs_attr_group;

I've copied this from the janz-ican3 driver[1].

regards, Marc

[1] http://lxr.linux.no/linux+v2.6.37/drivers/net/can/janz-ican3.c#L1682

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig184E52346692D505E3A2CC7F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0sRYoACgkQjTAFq1RaXHPc8wCfRIxJSbONipuTaZuGXypkQpNP
JGIAn1BkXv1D2LBpWs96PkEQkRaIB4PF
=qlB8
-----END PGP SIGNATURE-----

--------------enig184E52346692D505E3A2CC7F--

--===============6357765106408314792==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6357765106408314792==--
