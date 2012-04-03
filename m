From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Tue, 03 Apr 2012 17:33:40 +0200
Message-ID: <4F7B1854.90106@pengutronix.de>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com> <4F7AF0C7.7020506@grandegger.com> <331ABD5ECB02734CA317220B2BBEABC1317D85D0@DBDE01.ent.ti.com> <4F7AFFEC.1010805@pengutronix.de> <331ABD5ECB02734CA317220B2BBEABC1317D86F7@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig39D5EC57251C2350EAE5D01F"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"m.kleine-budde@pengutronix.de" <m.kleine-budde@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Gole, Anant" <anantgole@ti.com>, "Nori, Sekhar" <nsekhar@ti.com>
To: "AnilKumar, Chimata" <anilkumar@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <331ABD5ECB02734CA317220B2BBEABC1317D86F7@DBDE01.ent.ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig39D5EC57251C2350EAE5D01F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/03/2012 04:29 PM, AnilKumar, Chimata wrote:
>>>> Please explain why this CAN controller cannot be handled by the exis=
ting
>>>> C_CAN driver, eventually with some extensions. The register layout s=
eems
>>>> almost identical, at least.
>>>>
>>>> Wolfgang.
>>>>
>>>
>>> These are the some of the pointers I can say, why I had gone for sepa=
rate
>>> file instead of existing driver:
>>> * In case of D_CAN driver we can see all the registers are 32bit leng=
th
>>>   but in case of C_CAN registers are in 16bit length.
>>
>> How many bits in these 32 bit registers are used?
>=20
> In some cases (D_CAN_TXRQ, D_CAN_INTPND, D_CAN_MSGVAL) I have used all =
the
> bits, in some cases used few bits.
>=20
> Roughly I can say that its (higher 16bits) % of usages is similar as co=
mpare
> to 16bits=20
>=20
> While checking the status of TXRequest registers and INT pending regist=
er,
> which is a hot code path, we have to put if checks for register access.=


The c_can already has a c_can_read_reg32() function. It's for example
used in the rx_poll function. You can make it a function pointer (i.e.
pric->read_reg32()) for easy abstraction.

>>> * Some of the registers, bit masks are different, so we have to add
>>>   checks on every API for differentiating the kind of device
>>
>> Which registers are this? Can you give us an example?
>=20
> I am pointing out some of the resisters
> * Single registers in case of D_CAN but multiple register in case of C_=
CAN
>   So masks will change MASK, ARB, INTPND
> * D_CAN_IFCMD is the combination of COMM request and COMM mask register=
s

Maybe you can use the read_reg32 function on both c_can and d_can.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig39D5EC57251C2350EAE5D01F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk97GFgACgkQjTAFq1RaXHOV6QCeMM8f8o6v9akR5R3pAYshVXiZ
fjoAn1ipJ/AAbCzgB60NVQ8AbOqcoc40
=oOjd
-----END PGP SIGNATURE-----

--------------enig39D5EC57251C2350EAE5D01F--
