From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 15:06:02 +0100
Message-ID: <569F944A.4090201@pengutronix.de>
References: <1452538083-7331-5-git-send-email-marex@denx.de>
 <569F63C4.4070708@pengutronix.de> <569F675D.1070903@pengutronix.de>
 <201601201358.04790.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Ecj3AMVjhsVglsfQpME1WnMU0d90upP7x"
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60426 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcATOGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:06:14 -0500
In-Reply-To: <201601201358.04790.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ecj3AMVjhsVglsfQpME1WnMU0d90upP7x
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 01:58 PM, Marek Vasut wrote:
> On Wednesday, January 20, 2016 at 11:54:21 AM, Marc Kleine-Budde wrote:=

>> On 01/20/2016 11:39 AM, Marc Kleine-Budde wrote:
>>>> +/* IFI CANFD private data structure */
>>>> +struct ifi_canfd_priv {
>>>> +	struct can_priv		can;	/* must be the first member */
>>>> +	struct napi_struct	napi;
>>>> +	struct net_device	*ndev;
>>>> +	struct device		*device;
>>>
>>> Nitpick: This variable is write only, correct? I can fix this while
>>> applying the patch.
>>>
>>>> +	void __iomem		*base;
>>>> +};
>>>
>>> Otherweise looks good.
>=20
> It's write-only, yeah. What would you propose to change here ?

Remove it completely. :D

>> Until compiling:
>>> drivers/net/can/ifi_canfd/ifi_canfd.c:486:40: warning: cast truncates=

>>> bits from constant value (ffffffff7ffffffd becomes 7ffffffd)
>>> drivers/net/can/ifi_canfd/ifi_canfd.c:640:9: warning: cast truncates
>>> bits from constant value (ffffffff7fffffff becomes 7fffffff)
>>> drivers/net/can/ifi_canfd/ifi_canfd.c:676:9: warning: cast truncates
>>> bits from constant value (ffffffff7fffffff becomes 7fffffff)
>>
>> target is ARMv5 with gcc version 4.9.2, compiled with C=3D2 using spar=
se
>> v0.5.0.
>=20
> It's again the BIT() macro :-/ Do you have any idea how to fix this ple=
ase ?
> Doing something like u32 foo =3D ~BIT(31); triggers this splat and I am=
 running
> out of ideas how to fix that.

-#define IFI_CANFD_INTERRUPT_SET_IRQ            BIT(31)
+#define IFI_CANFD_INTERRUPT_SET_IRQ            ((u32)BIT(31))

=2E..or change the bit to "30" :D

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Ecj3AMVjhsVglsfQpME1WnMU0d90upP7x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn5RKAAoJEP5prqPJtc/HUY4H/2hOAfWB1GY3XE5GaAvPfEpx
t4j3laVoM9SEjEGDm645jwWj8zWFEM2WefELtsaiI1OJ98m9NMDs2eAta7i0kfI1
FM0v7f8bDF9c8TX11YNTj6p5j813w/vNUSMlkaV0vlVVIXg4y9T/KCBPbjg455nD
4H491CH5Z8QsGfTpQHPDshX6YWmw/O5a36g9o+t5s7JAcuMjexTtOiynFw1IdKcn
g5er/blpbe6jNlwcnY/NuhaUWk+CpjOixd5IVI8XKCyn4QIer5aC4dlZlU24BMuH
mDfPQbbH/MQn+pEYlNS6xATaqZSYWfbfRetCH3Hipim1IlGVcsl7I9roNyIlBfo=
=Pef9
-----END PGP SIGNATURE-----

--Ecj3AMVjhsVglsfQpME1WnMU0d90upP7x--
