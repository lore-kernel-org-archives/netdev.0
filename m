From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 17:20:12 +0100
Message-ID: <4F0C653C.3020902@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com> <4F0C31F1.20908@essax.com> <4F0C4EA8.7060002@grandegger.com> <4F0C63C6.5080305@essax.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCCBC4A3989BAE47D880963E3"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55717 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472Ab2AJQUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 11:20:25 -0500
In-Reply-To: <4F0C63C6.5080305@essax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCCBC4A3989BAE47D880963E3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/10/2012 05:13 PM, Wolfgang Zarre wrote:
> Hello Wolfgang,
>=20
>> On 01/10/2012 01:41 PM, Wolfgang Zarre wrote:
>>> Hello David,
>>>>
>>>>> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>>>>>                             int reg, u8 val)
>>>>>     {
>>>>>         unsigned long base =3D (unsigned long)priv->reg_base;
>>>>> +    unsigned long flags;
>>>>>
>>>>> +    spin_lock_irqsave(&outb_lock, flags);
>>>>>         outb(reg, base);
>>>>>         outb(val, base + 1);
>>>>> +    spin_unlock_irqrestore(&outb_lock, flags);
>>>>
>>>> Is there a 'read_reg_indirect' function??
>>>
>>> Yes, there is.
>>>
>>>> If so it also needs to use the same mutex.
>>>
>>> Actually, I don't think that we have a problem with mutex
>>> beside that it's using just one inb() statement but having
>>> for sure with an interrupt between both outb() statements which
>>> seems to be critical for the cc770.
>>
>> But the indirect read function also sets the address register before
>> reading the data using inb(). This sequence should also not be
>> interrupted and therefore we need to synchronize. For the indirect
>> access of the SJA1000 we also need to add spinlocks. Wonder why nobody=

>> complained so far.
>=20
> So, if I understand correct that means that inb() can be interrupted
> between
> setting the address and reading. If this is the case then yes, we need
> spinlock if this is not the case then IMHO we wouldn't need or am I wro=
ng?

If I understand correct, this function is the problem:

> static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *pri=
v,
>                                              int reg)
> {
>         unsigned long base =3D (unsigned long)priv->reg_base;
>=20
>         outb(reg, base);

an interrupt can happen here, which does another indirect read or write
access, leaving "reg" pointing to the wrong register.

>         return inb(base + 1);
> }

Mar
c
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCCBC4A3989BAE47D880963E3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8MZT8ACgkQjTAFq1RaXHMSFQCghxmB5pUM6AVV0NOKWQ9YY5ia
KGAAniiw4AhwsYBVvMNY+IdN6EX0aTAr
=7QSg
-----END PGP SIGNATURE-----

--------------enigCCBC4A3989BAE47D880963E3--
