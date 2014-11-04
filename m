From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Tue, 04 Nov 2014 14:28:52 +0100
Message-ID: <5458D494.3040700@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-7-git-send-email-b29396@freescale.com> <5457B1D1.6080301@pengutronix.de> <20141104082505.GA8060@shlinux1.ap.freescale.net> <54589AC8.4010106@pengutronix.de> <20141104092651.GC8060@shlinux1.ap.freescale.net> <5458AB65.7000500@pengutronix.de> <5458D0FA.1040504@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="havlQAmuTjMHkw3keLmlXkABOhXQIB37n"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5458D0FA.1040504@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--havlQAmuTjMHkw3keLmlXkABOhXQIB37n
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2014 02:13 PM, Oliver Hartkopp wrote:
>=20
>=20
> On 04.11.2014 11:33, Marc Kleine-Budde wrote:
>> On 11/04/2014 10:27 AM, Dong Aisheng wrote:
>=20
>=20
>>> +       /* We meet an IC issue that we have to write the full 8
>>
>> At least on the *insert SoC name here*, an issue with the Message RAM
>> was discovered. Sending CAN frames with dlc less than 4 bytes will lea=
d
>> to bit errors, when the first 8 bytes of the Message RAM have not been=

>> initialized (i.e. written to). To work around this issue, the first 8
>> bytes are initialized here.
>=20
> Yes. Also put the current IP revision (3.0.x) into the comment.

Good idea - also add the SoC's mask revision.

> Did inform the Bosch guys from this issue - or is it already in some
> errata sheet?
>=20
>>
>>> +        * bytes (whatever value for the second word) in Message RAM =
to
>>> +        * avoid bit error for transmit data less than 4 bytes at the=

>>> first
>>> +        * time. By initializing the first 8 bytes of tx buffer
>>> before using
>>> +        * it can avoid such issue.
>>> +        */
>>> +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
>>> +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
>>> +
>>>          m_can_config_endisable(priv, false);
>>>   }
>>
>> Can you trigger the issue when sending CAN-FD frames with dlc > 8 && d=
lc
>> < 64?
>=20
> Just a nitpick:
>=20
> DLC can just be 0 .. 15

Correct, I was talking about the length

> and the length (struct canfd_frame.len) can be from 0 .. 64
>=20
> See:
>=20
> http://lxr.free-electrons.com/source/include/uapi/linux/can.h#L83
>=20
> That's the reason for all these helpers
>=20
> http://lxr.free-electrons.com/source/drivers/net/can/dev.c#L36
>=20
> that hide the evil "DLC" from userspace now and make 'len' a usable loo=
p
> variable as we were able to use the former dlc for classic CAN :-)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--havlQAmuTjMHkw3keLmlXkABOhXQIB37n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWNSUAAoJECte4hHFiupU+LgP/jn7xpzdB2LN1y/nOazcG7gK
DxLw6k+bCALnl+tuuHXy5R0yJ9Xqr6DqIgjzb3T8XNteVPc5fAgX3gMy7QC5DueH
MX9ybqgHpdmSCr4mYHmElOMXNGhqywmj53BwYZh8mOjX5oMhThSaCB3qz4/eVTsK
ePnoVSmwkNcAD05FbEB8UrHm4lXpDEowFah2jaDIXrgRrv+MY1AoPvhjfa0bzhZS
oJh3uMWTmHyKKoOAs1XUcqhhSvysioa/4p7xjpI6sZFpvNPOwfx56i/clUeu+Hef
X+s7jzv57WrVDtdsRfT1OhCL+1Kp3EyZk2DmET71uE8QuEDJgJ8zaEj96fGUalsy
ryKI8eyakczrlJpzxPTy0dHtt8IR3oDC+cLmSNWSEUO1vFIj23HltaKLwK7Z31N8
yCGZMkyy2SBEOQFla26FPAX56hznOV+zFWMdaa4IguTIuNVFeHGBkI2kmoi4A89D
DHza5V4UfuVa4DPvzax90CPXsSRWdePqCYvzAIY0mb6x3MlP8q8MX43PU++iKJWp
yJ42JtyP7CoIuFjOtoy3UmkI1PadhtmuqPZOWvE79RC1LLgdKJSv8NVRUdvmZszC
ogtduhukOVVDqTprilzJGziY6SXVUs3heYiINwtYvYrVmpr7DRvCRtJI+3QIRYON
9RW0TKbt+FzpGMcZv03T
=GG5J
-----END PGP SIGNATURE-----

--havlQAmuTjMHkw3keLmlXkABOhXQIB37n--
