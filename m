From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Wed, 2 Mar 2016 10:20:39 +0100
Message-ID: <56D6B067.306@pengutronix.de>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D5FE8E.1090400@pengutronix.de>
 <SG2PR06MB1038AC389CDB35916408A5D6C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="IfeGfFiTwtSbslWSMoKbt30NNDJaOGWdO"
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1038AC389CDB35916408A5D6C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IfeGfFiTwtSbslWSMoKbt30NNDJaOGWdO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/02/2016 09:41 AM, Ramesh Shanmugasundaram wrote:
>> Is the channel loopback mode configurable per channel? If so, please
>> remove the module parameter and make use of CAN_CTRLMODE_LOOPBACK to
>> configure it.
>=20
> The loopback setting is not truly a per channel attribute. It
> requires touching Rx rules which can be done only when the
> controller's global state is reset (during probe).
> CAN_CTRLMODE_LOOPBACK config option is possible only through
> .ndo_open of that channel but the global controller state needs to be
> operational by this time. As it is a global attribute & for the above
> reason, I choose the module option.

I see, ok then.

>>> CAN FD mode supports both Classical CAN & CAN FD frame formats. The
>>> controller supports ISO 11898-1:2015 CAN FD format only.
>>>
>>> This controller supports two channels and the driver can enable eithe=
r
>>> or both of the channels.
>>>
>>> Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs
>>> (one per channel) for transmission. Rx filter rules are configured to=

>>> the minimum (one per channel) and it accepts Standard, Extended, Data=

>>> & Remote Frame combinations.
>>
>> I see no locking for the tx-path.
> =20
> I am not sure why locking is needed in tx-path?=20

If the tx-path is shared between both channels you need locking as the
networking subsystem may send one frame to each controller at the same ti=
me.

> However, looking at it again, I should move the incrementing of head
> after the "sts" handing to be apt. What do you think?

With one producer (one SW instance) and one consumer (the HW) you can
write lockless code (if the HW allows it), but with two producers it's
not possible.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IfeGfFiTwtSbslWSMoKbt30NNDJaOGWdO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1rBnAAoJED07qiWsqSVqGK8H/19xU/on6yG2Y1Z6MYeyV2A6
DHDu8nqZ7L7vVEFpTkRPN9UgrD8Wx1rUyyJvpWEpu+fNAkBWZGexyqDz8uTaEMOb
0KS9TPOL3+oBNJ4yWn/H3Jmk0toR3C80ppy8f1wmUJ84whya/Rsz0f0rPoUNsI00
zgDJLbeursso6LlOllaHyJnyIMMF7jLccFHi++YGoKuXcmovAuQ4MCHZLNSoMHgI
KWZLRdDtDlGiZmeSmDm7OErqAHQg0Ge1aowql4gmjjTmzwzd3CpkP1AoBCm8JdxM
lD9emS/ZNVzsR5CJWbgb+PHGqabsjbSe/om3YjkbtViA+t490UnLx0/V9a6W4PQ=
=1dPQ
-----END PGP SIGNATURE-----

--IfeGfFiTwtSbslWSMoKbt30NNDJaOGWdO--
