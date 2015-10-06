From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 12/12] [RFC] can: avoid using timeval for uapi
Date: Tue, 6 Oct 2015 11:05:32 +0200
Message-ID: <56138EDC.8080501@pengutronix.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-13-git-send-email-arnd@arndb.de>
 <5612C69C.7020803@hartkopp.net> <7548522.iLToS4O3HD@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="dT3ARBDVtrIOv6XH9JCL5S2JmBsMlXwCJ"
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	linux-api@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <7548522.iLToS4O3HD@wuerfel>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dT3ARBDVtrIOv6XH9JCL5S2JmBsMlXwCJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/06/2015 10:32 AM, Arnd Bergmann wrote:
> On Monday 05 October 2015 20:51:08 Oliver Hartkopp wrote:
>>
>> I double checked some (more) BCM applications I have access to.
>>
>> E.g. https://github.com/linux-can/can-tests
>>
>> When you do a 'git grep ival1' there you get something like
>>
>> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec =3D 1;
>> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec =3D 0;
>> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec =3D 0;
>> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec =3D 0;
>> tst-bcm-dump.c: msg.msg_head.ival1.tv_sec       =3D timeout / 1000000;=

>> tst-bcm-dump.c: msg.msg_head.ival1.tv_usec      =3D timeout % 1000000;=

>> (..)
>>
>> So the usual way to assign values to ival1 and ival2 is NOT to assign =
an
>> existing struct timeval but to directly assign its tv_[u]sec elements.=

>=20
> Ok, very good.
>=20
>> I applied your bcm.h changes to my local can-tests tree and it compile=
s
>> without any problems - as expected. I don't see any serious drawback w=
ith your
>> idea. I wonder whether developers would ever notice this change ...
>>
>>> We could address problem a) by using '__u32' or 'int' members
>>> rather than 'long', but that would have a more significant
>>> downside in also breaking support for all existing 64-bit user
>>> binaries that might be using this interface, which is likely
>>> not acceptable.
>>
>> Indeed.
>>
>>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
>>
>> Thanks for your good suggestion to make the BCM API y2038 proof!
>>
>> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> Thanks.
>=20
> What is the normal path for CAN patches? Should I resend with your
> Ack and without the RFC for Marc to pick it up?

You can add my:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

add upstream the 2038 fixes as a block.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--dT3ARBDVtrIOv6XH9JCL5S2JmBsMlXwCJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWE47cAAoJEP5prqPJtc/HW8wH/1IU8lkWlJLAROnEZ+QzBEdK
DoKx9NPYnyNueTCYdFpMmsVg183Zr2RN2z4vn4YjCSbqgEzHPka1reP6MamvksGV
aQ6n7d0XNtvfCTXIqnpZgYrT3xCQWOmOxN7KcYzIHSQsPFYUg9brPTfmxdpky9+4
TTHzhHlIFtm+YGKbdDKJFOprnlDnvyrMZm9tvCzLnELRU1ywlLb8EJmHHRGZWoHT
/hJvB4ORhKWI22piByPMWFoNyH18CD3UWv0ZI2f0HE4vwcQ2YnlPebZxUfTF2lL2
X3b9FwyKPsotLrOxWP9zoexVwJ2AgDjKt19fjWFS/CphPR6jLmv2zzJOFFr/oZw=
=I4y3
-----END PGP SIGNATURE-----

--dT3ARBDVtrIOv6XH9JCL5S2JmBsMlXwCJ--
