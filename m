From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Wed, 2 Mar 2016 11:21:32 +0100
Message-ID: <56D6BEAC.10408@pengutronix.de>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D5FE8E.1090400@pengutronix.de>
 <SG2PR06MB1038AC389CDB35916408A5D6C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56D6B067.306@pengutronix.de>
 <SG2PR06MB1038DD32D284801452BA633EC3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="EOqqlLP077GJ35Qm6UgDcw51wwPOgcTih"
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
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1038DD32D284801452BA633EC3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EOqqlLP077GJ35Qm6UgDcw51wwPOgcTih
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/02/2016 11:08 AM, Ramesh Shanmugasundaram wrote:
>>>> I see no locking for the tx-path.
>>>
>>> I am not sure why locking is needed in tx-path?
>>
>> If the tx-path is shared between both channels you need locking as the=

>> networking subsystem may send one frame to each controller at the same=

>> time.
>=20
> Yes. Tx completion interrupt is shared by both channels but the Tx
> FIFO, echo skbs, head, tail are maintained on a per channel basis.=20
> Yes, net subsystem can send one frame to each channel at the same
> time and the tx completion interrupt handler will traverse each
> channel & update per channel context accordingly.

Ok. Which instruction starts the transmit? Please add a comment to the
code. You stop the tx_queue after this, so your code is racy, as the
interrupt might happen in between.

>>> However, looking at it again, I should move the incrementing of head
>>> after the "sts" handing to be apt. What do you think?
>>
>> With one producer (one SW instance) and one consumer (the HW) you can
>> write lockless code (if the HW allows it), but with two producers it's=
 not
>> possible.
>=20
> For a channel represented as netdev, there is still one producer (one
> SW instance) isn't it? net acquires lock before calling xmit. The
> consumer is tx completion interrupt handler which updates per channel
> attributes only.

Ok - I haven't looked at the code in depth yet. Now it's clear, that
just the tx interrupt is shared.

> Sorry if I am annoying. I have tested this with two channels
> transmitting & receiving at the same time and it works fine. If I am
> missing lock, I would like to understand it thoroughly before making
> the change.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--EOqqlLP077GJ35Qm6UgDcw51wwPOgcTih
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1r6tAAoJED07qiWsqSVqNHYIAIhiBlD+W3zYRUuXAj40j691
lIsSEQ4CQf6GZB/e3BauDVYR7Kzy75buNTC8vE8I01u1IXDcjeFmDyy0aF288oCw
B8oqeisYderLDhPg5uJQ4HUclN4mwtoiGKW0co2FG4Xsag6jh4m4Yv/BOObSediH
HczMST59ap3hNnjd5VkHb2fwsJ/+I82lIY+i0AQ3Za2T3mLkSY5JPcXTXDA4y5BC
XrjmEfALPxlpCfrYWsx3n19qLVcVvSd4av/yv87eQmND6Li0zm9N8V8PSZUCA8fx
Gt8MWOO1mGrPPgvzkMTNXMq1K0MOikhU09QCnwaPNQazfcD2XAIuHH97DIjYFXo=
=8Llr
-----END PGP SIGNATURE-----

--EOqqlLP077GJ35Qm6UgDcw51wwPOgcTih--
