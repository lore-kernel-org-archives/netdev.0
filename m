From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: M_CAN message RAM initialization AppNote  - was: Re: [PATCH V3
 3/3] can: m_can: workaround for transmit data less than 4 bytes
Date: Thu, 06 Nov 2014 10:00:34 +0100
Message-ID: <545B38B2.6000003@pengutronix.de>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-3-git-send-email-b29396@freescale.com> <545A3451.2090302@pengutronix.de> <545A692E.40002@hartkopp.net> <20141106015716.GB7642@shlinux1.ap.freescale.net> <545B1D71.4000408@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="1LnNlr9sPCIoB1VBDMCBUCqODasEWf3fD"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <545B1D71.4000408@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1LnNlr9sPCIoB1VBDMCBUCqODasEWf3fD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/06/2014 08:04 AM, Oliver Hartkopp wrote:
> On 06.11.2014 02:57, Dong Aisheng wrote:
>> On Wed, Nov 05, 2014 at 07:15:10PM +0100, Oliver Hartkopp wrote:
>=20
>>> The Message RAM is usually equipped with a parity or ECC functionalit=
y.
>>> But RAM cells suffer a hardware reset and can therefore hold
>>> arbitrary content at startup - including parity and/or ECC bits.
>>>
>>> So when you write only the CAN ID and the first four bytes the last
>>> four bytes remain untouched. Then the M_CAN starts to read in 32bit
>>> words from the start of the Tx Message element. So it is very likely
>>> to trigger the message RAM error when reading the uninitialized
>>> 32bit word from the last four bytes.
>>>
>>> Finally it turns out that an initial writing (with any kind of data)
>>> to the entire message RAM is mandatory to create valid parity/ECC
>>> checksums.
>>>
>>> That's it.
>>>
>>
>> Thanks for sharing this information.
>> Does it mean this issue is related to the nature of Message RAM and is=

>> supposed to exist on all M_CAN IP versions?
>=20
> From what I know from the 3.1.x revision there's no change regarding
> IR.BRU and IR.BEC - so I would assume this to stay on all M_CAN IP
> revisions.
>=20
> But after some sleep I wonder if this patch [3/3] would need an update =
too.
>=20
> Writing to the TX message RAM is obviously no workaround but a valid an=
d
> needed initialization process.
>=20
> I would tend to make this patch:
>=20
> ---
>=20
> can: m_can: add missing TX message RAM initialization
>=20
> The M_CAN message RAM is usually equipped with a parity or ECC
> functionality.
> But RAM cells suffer a hardware reset and can therefore hold arbitrary
> content at startup - including parity and/or ECC bits.
>=20
> To prevent the M_CAN controller detecting checksum errors when reading
> potentially uninitialized TX message RAM content to transmit CAN frames=

> the TX message RAM has to be written with (any kind of) initial data.
>=20
> ---
>=20
> Then the code should memset() the entire TX FIFO element - and not only=

> the 8 data bytes we are addressing now.

No literal memset() as this is iomem

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1LnNlr9sPCIoB1VBDMCBUCqODasEWf3fD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWziyAAoJECte4hHFiupU8+MP/icuevFzr0fogxmg75RpZY/j
6x+cXI7N3rpPRtIGfXE3WtwiExSyPyhMOqxbgaLvcWMr5VtmhpW0rCLPbAqkZbC9
PpKmPqrj8l+D16/iD7P5hay2EBjJa6u9VjFDiKBu8mfv3wdh+MrvbjyaSD4NnSoh
pbsIyn+9DEviUSVyhYLuk/iXdktFg9+VAlOHVKbaDdz0JVXNKeNJ1lmeJQJOQK/n
XaNrVxJAk6b/2w34/dS5xptwfZgWiF3EkOzuXpK+we2GfRivEmXPa4X+II1oBTt3
JWoktkuAHyetdyBc/T6kSmfB0grJVaAjuKfAUtRoKQCp4kk9lHb8JWi+uUOjp5zm
6LH1x7QG1rxXr3+XGWTZt9C7hXSRqxnAij7/9chm66tXsZKX6iqW8uC5yEWwh0nH
uPOOqh1PUogFh/4HPh7i+4JHERBvBK++6DnHDA28rRGpiRuElDEYqjlRdzXToB5Q
1Vfbj2Dx4Lg0UZt8EVprAMeyH0DDda9maPeDwGp+YVzpx7wy0vaxd0CbHcZzAnht
Jv3Oveqib7VzVB6610FB/STWSv8Fq4WAqY0Le6BfDmoEjtNbyigi+pZ2g5cf5KNG
jIZzpphKMsRabxg9+3tWrLNHsxMvhwNwTHDeMuLD1SFPgtXtRqN7qY5AnXu/ThVU
f333fH96ycymvEll/NaH
=EZ+5
-----END PGP SIGNATURE-----

--1LnNlr9sPCIoB1VBDMCBUCqODasEWf3fD--
