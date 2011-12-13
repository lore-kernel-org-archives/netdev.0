From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Tue, 13 Dec 2011 13:53:04 +0100
Message-ID: <4EE74AB0.1080106@pengutronix.de>
References: <4EE61928.10608@grandegger.com> <4EE61E3D.2090303@pengutronix.de> <4EE62141.8010305@grandegger.com> <4EE7416E.8070203@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig96058EE6412D136C2D476784"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE7416E.8070203@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig96058EE6412D136C2D476784
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/13/2011 01:13 PM, Wolfgang Grandegger wrote:
> On 12/12/2011 04:44 PM, Wolfgang Grandegger wrote:
>> On 12/12/2011 04:31 PM, Marc Kleine-Budde wrote:
>>> On 12/12/2011 04:09 PM, Wolfgang Grandegger wrote:
>>>> As pointed out by Reuben Dowle and Lothar Wa=DFmann, the TWRN_INT,
>>>> RWRN_INT, BOFF_INT interrupt sources need to be cleared as well
>>>> to avoid interrupt flooding, at least for the Flexcan on i.MX28
>>>> SOCs. Furthermore, the interrupts are only cleared, if really one
>>>> of those interrupt sources are pending (which is not the case for
>>>> rx and tx done).
>>>>
>>>> CC: Reuben Dowle <Reuben.Dowle@navico.com>
>>>> CC: Lothar Wa=DFmann <LW@KARO-electronics.de>
>>>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>>>
>>> Have you tested on mx25/mx35, does it have any negative side effects?=

>>> My schedule is full until Friday, sorry cannot test here.
>>
>> Not yet. But it's not critical. Only the pending interrupt flags are
>> cleared. Maybe somebody else out there could do some testing... before=
 I
>> get hold of a MX35PDK board.
>=20
> I got my MX35PDK board working and can confirm, that the patch works on=

> a i.mx35 as well. My testing also confirms, that the ESR TWRN_INT,
> RWRN_INT, FLEXCAN_ESR_BOFF_INT do not function as documented. These
> flags do show up once, together with ERR_INT, and then, after clearing,=

> never again. Obviously a bug in the Flexcan logic. From the feedback we=

> can say, that only the i.MX28 does behave differently (=3D=3Dcorrectly)=
=2E All
> other seem to work with the current code:
>=20
>  Flexcan on
>  - i.mx25
>  - i.mx35
>  - i.mx53
>  - P1010/P1020

I'm adding the patch to linux-can. I think this is a stable candidate
for v2.6.39 and newer (mx28 suport was added in 2.6.39).

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig96058EE6412D136C2D476784
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7nSrUACgkQjTAFq1RaXHPW5QCghM4MMLJzgNtVWe6TTzKz1X1c
AQIAn0qBNnQced8uawYvjV9o8b7vLpeu
=yzHp
-----END PGP SIGNATURE-----

--------------enig96058EE6412D136C2D476784--
