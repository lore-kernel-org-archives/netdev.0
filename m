From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/1] can: sja1000: clear interrupts on start
Date: Wed, 11 Nov 2015 13:37:12 +0100
Message-ID: <56433678.1090104@pengutronix.de>
References: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
 <5642F6A5.5070301@pengutronix.de>
 <CAJ=nTssqwtYAos67GRr8fOzsm63v_Bx+GKEWriOjbTALuzv-0g@mail.gmail.com>
 <5643132A.7080504@pengutronix.de>
 <CAJ=nTstPCev0TGjZCYkzf4qX+6NUUv8+-6PeVEKL9bcOwBKc0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="aUmr3vLjdsBaCOFWei9nSTrEK8wna2DWb"
Cc: wg@grandegger.com, andri.yngvason@marel.com,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christian Magnusson <Christian.Magnusson@semcon.com>
To: Mirza Krak <mirza.krak@hostmobility.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAJ=nTstPCev0TGjZCYkzf4qX+6NUUv8+-6PeVEKL9bcOwBKc0A@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aUmr3vLjdsBaCOFWei9nSTrEK8wna2DWb
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/11/2015 01:29 PM, Mirza Krak wrote:
>> Can you put a scope on the interrupt pin and see if it's a problem of
>> the SoC and/or Linux or the SJA1000 not pulling the IRQ line.
>=20
> A little demonstration on what it looks like when the system is
> resumed (added a printk in sja1000_start without my patch, though my
> printk also clears IR register):
>=20
> root@mx4-vcc:/opt/hm# ip -det link show can0
> 33: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state
> UNKNOWN mode DEFAULT qlen 10
>     link/can
>     can state ERROR-ACTIVE (berr-counter tx 0 rx 128) restart-ms 0
>     bitrate 500000 sample-point 0.875
>     tq 250 prop-seg 3 phase-seg1 3 phase-seg2 1 sjw 1
>     sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 12000000
> root@mx4-vcc:/opt/hm# ifconfig can0 down
> root@mx4-vcc:/opt/hm# ifconfig can0 up
> [ 1612.621187] sja1000: MOD: 0x1
> [ 1612.640992] sja1000: SR: 0x7c
> [ 1612.660039] sja1000: IR: 0x24
>=20
> Also did a measurement with the scope, it is the SJA1000 chip not
> pulling the IRQ line.
>=20
> I can actually send one frame when the controller is in this state but
> never get a TI interrupt.

Thanks for testing.

[...]

>>> Yes, resume code should be implemented to handle this and other
>>> problems (receive data). But still a DOWN/UP procedure should clear
>>> any previous state that could exist in the controller registers.
>>
>> I'll add your patch to can/master and add stable on Cc. Looking forwar=
d
>> for some suspend/resume code :)
>=20
> Looking forward to writing suspend/resume code :).
>=20
> Some cred should go to Christian (added him to CC) for finding this
> problem and reporting it to me.

I'll add a

Reported-by: Christian Magnusson <Christian.Magnusson@semcon.com>

to the patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--aUmr3vLjdsBaCOFWei9nSTrEK8wna2DWb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWQzZ4AAoJEP5prqPJtc/HEIMIALxPUeTnFaScWM+EpXTCAvLg
YPsoWPubcn9MF6PAhiAgltTtZY9OY2oZBveoN5fGTJfYASYsipzVYmuOK4lA4vWk
a9Z/iJqbeC9o5rFOba5JgyKz+izUurz+X94J6CYJyBIfuNCrG84zp1iz0iE//4aP
yPMJKlgp/UJ/k1ZfyL3gQuG1vymozKLrZQNRasd5A6Ez7jIOL/L9llvavpjhTM0S
KlI4/xWK15MWDTQFDa5uYf12bt90Qwb8qXhGGLGtywpQLIvEsbn1v6rJzIj4dsxI
Uy+Fk9IevyoOXyZmv/ZuL/52GOA3rqNouT/zDG/EZweB/UL5mCWEby2d1Hg+0qA=
=zQre
-----END PGP SIGNATURE-----

--aUmr3vLjdsBaCOFWei9nSTrEK8wna2DWb--
