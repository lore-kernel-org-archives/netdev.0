From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/1] can: sja1000: clear interrupts on start
Date: Wed, 11 Nov 2015 11:06:34 +0100
Message-ID: <5643132A.7080504@pengutronix.de>
References: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
 <5642F6A5.5070301@pengutronix.de>
 <CAJ=nTssqwtYAos67GRr8fOzsm63v_Bx+GKEWriOjbTALuzv-0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lor47OJNnL11Q5vmEKObO4sWAHBAmiOlN"
Cc: wg@grandegger.com, andri.yngvason@marel.com,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Mirza Krak <mirza.krak@hostmobility.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAJ=nTssqwtYAos67GRr8fOzsm63v_Bx+GKEWriOjbTALuzv-0g@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lor47OJNnL11Q5vmEKObO4sWAHBAmiOlN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/11/2015 10:54 AM, Mirza Krak wrote:
> 2015-11-11 9:04 GMT+01:00 Marc Kleine-Budde <mkl@pengutronix.de>:
>> This problem occurs only an hardware, where the SJA1000 is powered
>> during system suspend?
>=20
> Correct, and the controller is in UP state.
>=20
>> Doesn't the SJA1000 trigger an interrupt that is detected after
>> resuming? You add the fix to the open() function, which is triggered
>> during $(ifconfig up), how is related to suspend/resume? Does the
>> network layer call $(ifconfig down) during shutdown?
>=20
> It does not trigger another interrupt.

Can you put a scope on the interrupt pin and see if it's a problem of
the SoC and/or Linux or the SJA1000 not pulling the IRQ line.

> In our tests we have seen that IE and EPI flags are set in the IR
> registered when we resume the system. If we do not clear these two
> flags it does not produce any other interrupts. Setting the controller
> in to reset mode does not clear the IE and EPI flags, I can understand
> that IE flag is not cleared as this is stated in the data-sheet, can
> not explain why EPI flag is not cleared though as data-sheet states 0
> (reset) for both hardware reset and SETTING MOD.0 BY SOFTWARE (which
> is the reset-mode)
>=20
> Reason I put it in open() is so at least a DOWN/UP procedure returns
> the controller to an operating state. Also if we do an UP we should
> clear any earlier states that might exist in the registers like we do
> with error counters and error code capture.

Yes - makes sense to have it in open().

> Network layer does not call $(ifconfig down) during shutdown.
>=20
>> There isn't any suspend/resume code in the sja1000 driver, for me it
>> seems that we should add resume code that handles this problem.
>=20
> Yes, resume code should be implemented to handle this and other
> problems (receive data). But still a DOWN/UP procedure should clear
> any previous state that could exist in the controller registers.

I'll add your patch to can/master and add stable on Cc. Looking forward
for some suspend/resume code :)

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--lor47OJNnL11Q5vmEKObO4sWAHBAmiOlN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWQxMqAAoJEP5prqPJtc/HzkEIAJV8V6LUqwQGJNsfbmpjAqGq
DAckW5MEvpTcUf5pTtLbrTm9ey4oNjRBNkgVeASbNgZciUtRAVtnlAtSp+/jEkjz
tisBKdi8yi/b+gJhrQ6noXOHP03jEYpXr1lxiEuD8wOjJt6targJ/D26Apns01U+
9GqJqtJat8oQwFzVNrpPG1EHaYaOAGNks5wQl5Ejrb+vkpnNq/RVK6r7Czvhmuos
IqsMOmAoDZz3/mXSdDqsHo6VXZylc64aXGS5sLv2i6yXBKZKP9n5MRt/0yqj1cfU
y4QXsB2+aGNbDbwiANGeMLtO1bePjCVOAJ1GZoBtONw/8HHJZcp4/SasF5Qq+BY=
=qGO4
-----END PGP SIGNATURE-----

--lor47OJNnL11Q5vmEKObO4sWAHBAmiOlN--
