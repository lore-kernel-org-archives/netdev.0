From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V3 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 15:46:58 +0100
Message-ID: <569F9DE2.10405@pengutronix.de>
References: <569F944A.4090201@pengutronix.de>
 <1453300419-5716-1-git-send-email-marex@denx.de>
 <569F9C37.60007@pengutronix.de> <201601201541.53246.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fXx8eWKK2VdclcvRfGhQlbnTXeIShBpTQ"
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:38603 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933983AbcATOrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:47:09 -0500
In-Reply-To: <201601201541.53246.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fXx8eWKK2VdclcvRfGhQlbnTXeIShBpTQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 03:41 PM, Marek Vasut wrote:
> On Wednesday, January 20, 2016 at 03:39:51 PM, Marc Kleine-Budde wrote:=

>> On 01/20/2016 03:33 PM, Marek Vasut wrote:
>>> The patch adds support for IFI CAN/FD controller [1]. This driver
>>> currently supports sending and receiving both standard CAN and new
>>> CAN/FD frames. Both ISO and BOSCH variant of CAN/FD is supported.
>>>
>>> [1] http://www.ifi-pld.de/IP/CANFD/canfd.html
>>>
>>> Signed-off-by: Marek Vasut <marex@denx.de>
>>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>>> ---
>>> V2: - Move request_irq()/free_irq() into
>>> ifi_canfd_open()/ifi_canfd_close()
>>>
>>>       just like other drivers do it to prevent crash when reloading
>>>       module.
>>>    =20
>>>     - Fix Woverflow complains on x86_64 and itanium, exactly the same=
 way
>>>    =20
>>>       as in commit dec23dca5a9ca4b9eb2fb66926f567889028b904 .
>>>
>>> V3: - Hopefully fix all problems with BIT(31) by adding more u32 cast=
s.
>>>
>>>     - Drop struct device from struct ifi_canfd_priv .
>>>
>>> NOTE: The driver is surprisingly similar to m_can, but the register
>>>
>>>       layout of the IFI core is completely different, so it's clear
>>>       that those are two different IP cores.
>>>
>>> ---
>=20
> [...]
>=20
> Hi,
>=20
>>> +static irqreturn_t ifi_canfd_isr(int irq, void *dev_id)
>>> +{
>>> +	struct net_device *ndev =3D (struct net_device *)dev_id;
>>> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
>>> +	struct net_device_stats *stats =3D &ndev->stats;
>>> +	const u32 rx_irq_mask =3D IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY |
>>> +				IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY_PER;
>>> +	const u32 tx_irq_mask =3D IFI_CANFD_INTERRUPT_TXFIFO_EMPTY |
>>> +				IFI_CANFD_INTERRUPT_TXFIFO_REMOVE;
>>> +	const u32 clr_irq_mask =3D (u32)(~(IFI_CANFD_INTERRUPT_SET_IRQ |
>>> +					 IFI_CANFD_INTERRUPT_ERROR_WARNING));
>>
>> I've squashed:
>>>> -       const u32 clr_irq_mask =3D (u32)(~(IFI_CANFD_INTERRUPT_SET_I=
RQ |
>>>> -                                      =20
>>>> IFI_CANFD_INTERRUPT_ERROR_WARNING)); +       const u32 clr_irq_mask =
=3D
>>>> ~(IFI_CANFD_INTERRUPT_SET_IRQ | +                                =20
>>>> IFI_CANFD_INTERRUPT_ERROR_WARNING);
>>
>> and the driver compiles without warnings.
>=20
> It doesn't , try with x86_64_defconfig, it will complain with -Woverflo=
w
> on gcc 4.9 or newer. That's what the kernel robot complained about in V=
1
> of the patch too.

Doh! Right, let's try this:

>> -#define IFI_CANFD_INTERRUPT_ERROR_WARNING      BIT(1)
>> +#define IFI_CANFD_INTERRUPT_ERROR_WARNING      ((u32)BIT(1))

> I'd be happy to be proven wrong though.

/me too

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fXx8eWKK2VdclcvRfGhQlbnTXeIShBpTQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn53iAAoJEP5prqPJtc/HI74H/ifqpQ/NRk72Peu7JrPJIl57
gxrKmRUygeE6ivxvnvG3PAOHBiptNpYu5UtAeiAiG8TQ+6TJHb+YeGKbD05umrFu
ATfEYRXFWv8TFsJRL0O1VOyySWsBOfb9YjWwVvm6KzDVYA5jDcXMhiZqS7pPWlc0
jeqh6077Xw37tk+p8/dBoihArzxCMgI19a414OaEr2A6QFIwyTfQLuJaYVUD699z
Q812YaqENidGfwNto0CigzWLAxF7c633+8TMGCsek1iBn9T96jVgr+CN+S5fiFTs
VCklhSijcXegMORRw3omqRH1IFIGUJ+rupxFr8ySbxatwBwk8TSy0lfbJsQ4ZPE=
=0DIL
-----END PGP SIGNATURE-----

--fXx8eWKK2VdclcvRfGhQlbnTXeIShBpTQ--
