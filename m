From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 13:21:32 +0200
Message-ID: <4C1B56BC.1050303@pengutronix.de>
References: <20100617105201.GA2015@bluebox.local>	<4C1B4098.3090800@grandegger.com>
	<4C1B4796.3060506@pengutronix.de> <4C1B4B85.3010905@grandegger.com>
	<4C1B4DF0.2090103@pengutronix.de> <4C1B52A7.3060607@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5697370433625418308=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C1B52A7.3060607-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============5697370433625418308==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAFDCFDFE6A0A21398054C256"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAFDCFDFE6A0A21398054C256
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> On 06/18/2010 12:44 PM, Marc Kleine-Budde wrote:
>> Wolfgang Grandegger wrote:
>>> On 06/18/2010 12:16 PM, Marc Kleine-Budde wrote:
>>>> Wolfgang Grandegger wrote:
>>>>> Hi Hans-J=FCrgen,
>>>>>
>>>>> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>>>>>> This adds a driver for FlexCAN based CAN controllers,
>>>>>> e.g. found in Freescale i.MX35 SoCs.
>>>>>>
>>>>>> The original version of this driver was posted by Sascha Hauer in =
July 2009:
>>>>>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>>>>>
>>>>>> I took this version, added NAPI support, and fixed some problems f=
ound
>>>>>> during testing. Well, here is the result. Please review.
>>>>> I briefly browsed the patch and various bits and pieces are missing=
 or
>>>>> not correctly implemented. Marc already pointed out a few of them:
>>>>>
>>>>> - I do not find can_put/get_echo_skb functions in the code. How is
>>>>>   IFF_ECHO supposed to work?
>>>> the driver uses hardware loopback
>>> OK, then
>>>
>>>   dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
>>>
>>> should be used (and TX_ECHO_SKB_MAX removed) in Hans-J=FCrgens driver=
=2E
>>>
>>>>> - Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()=

>>>>>   seems to be missing.
>>>>>
>>>>> - Make use of alloc_can_skb() and alloc_can_err_skb().
>>>> the last two points are already addressed in my version of the drive=
r.
>>> I do not see support for CAN_CTRLMODE_BERR_REPORTING in your driver
>>> (which has nothing to do with do_get_berr_counter).
>> oh yes...sorry, got confused.
>>
>> However I implemented CAN_CTRLMODE_BERR_REPORTING, i.e. turning of the=

>> bit error interrupts by default. This has the effect that no bus warni=
ng
>> and bus passive interrupt was signalled.
>>
>> I should add a comment to my driver.
>=20
> I'm confused, CAN_CTRLMODE_BERR_REPORTING means that the user can enabl=
e
> bus error reporting, which seems not be handled in the driver your sent=
=2E
> See:
>=20
> http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L134
> http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L588

Which interrupts does "IRQ_BEI" include? What should
CAN_CTRLMODE_BERR_REPORTING do?

Looking at:
http://lxr.linux.no/linux+v2.6.34/drivers/net/can/sja1000/sja1000.c#L393
it seems that BEI on the SJA just effects bit, form and stuff errors.

If I disable the corresponding interrupt in the flexcan. This is
ERR_MSK, (1 << 14 in CTRL), I don't get error warning or error passive
interrupts either. I'm not sure about the bus off interrupt.

=46rom my point of view this is not that what CAN_CTRLMODE_BERR_REPORTING=

should do, is it?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAFDCFDFE6A0A21398054C256
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkwbVsEACgkQjTAFq1RaXHP8eACfRlSXd74vbPAruTkJiFqncyO6
daUAoJLainmilniEgJuxWa7Rk/cYc3lq
=ONIm
-----END PGP SIGNATURE-----

--------------enigAFDCFDFE6A0A21398054C256--

--===============5697370433625418308==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5697370433625418308==--
