From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 12:49:00 +0100
Message-ID: <531077AC.7050804@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<52DCE9E4.7010209@pengutronix.de>	<52E3148E.2010608@cogentembedded.com>	<52FCB6C5.6020001@pengutronix.de>	<53069445.80408@cogentembedded.com>	<5310521E.6000708@pengutronix.de>	<53107007.7050802@cogentembedded.com>	<531074F5.8090702@pengutronix.de> <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="JhuOLQkWXfUjKKfjINw2kbhWkVb68r90b"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57130 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbaB1LtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 06:49:08 -0500
In-Reply-To: <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JhuOLQkWXfUjKKfjINw2kbhWkVb68r90b
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2014 12:41 PM, Geert Uytterhoeven wrote:
> On Fri, Feb 28, 2014 at 12:37 PM, Marc Kleine-Budde <mkl@pengutronix.de=
> wrote:
>>>> A 32 bit read/modify/write is a standard operation, nothing special,=
 no
>>>> need to worry about byte swapping or anything like this.
>>>
>>>    Oh, really? 8-)
>>>    Don't you know that read[bwlq]() assume little-endian memory layou=
t
>>> and to read from big-endian 32-bit register one normally needs readl_=
be()?
>>
>> I assume you are on little endian ARM only (for now).
>>
>> If you use a standard 32 bit read, then modify the correct bits in tha=
t
>> 32 bit word and write it back, with the corresponding 32 bit write
>> everything should be fine. For this usecase you just have yo figure ou=
t
>> which 24 of the 32 bit are the one you have to change and which are th=
e
>> 8 that must not be modified.
>>
>> Looking at the register layout:
>>
>>> +     u8 bcr[3];      /* Bit Configuration Register */
>>> +     u8 clkr;        /* Clock Select Register */
>>
>> I think clkr would be the lowest 8 bit and bcr[] are the upper 24.
>=20
> That would be the outcome on big endian ;-)

Doh! Yes, correct.
The point is, just read/modify the correct bits/write, should just work.
The driver has to be tested on BE ARM anyways, as this isn't the only 32
bit reg.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--JhuOLQkWXfUjKKfjINw2kbhWkVb68r90b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQd6wACgkQjTAFq1RaXHM5UgCgidq97zpV8nrbhY5TWtEjibHl
YukAn3MvFxAxODeMHSbRYjq3KVtqO+v5
=uvQe
-----END PGP SIGNATURE-----

--JhuOLQkWXfUjKKfjINw2kbhWkVb68r90b--
