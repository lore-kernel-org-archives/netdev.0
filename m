From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: Use correct type in sizeof() in nla_put()
Date: Fri, 30 Oct 2015 15:17:44 +0100
Message-ID: <56337C08.40001@pengutronix.de>
References: <1446209299-6250-1-git-send-email-marex@denx.de>
 <5633734A.3040504@pengutronix.de> <201510301501.28536.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="DA2807LQcp4ggLsn40NHkx3MQLjW9RgVu"
Cc: linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	netdev@vger.kernel.org
To: Marek Vasut <marex@denx.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <201510301501.28536.marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DA2807LQcp4ggLsn40NHkx3MQLjW9RgVu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/30/2015 03:01 PM, Marek Vasut wrote:
> On Friday, October 30, 2015 at 02:40:26 PM, Marc Kleine-Budde wrote:
>> On 10/30/2015 01:48 PM, Marek Vasut wrote:
>>> The sizeof() is invoked on an incorrect variable, likely due to some
>>> copy-paste error, and this might result in memory corruption. Fix thi=
s.
>>>
>>> Signed-off-by: Marek Vasut <marex@denx.de>
>>> Cc: Wolfgang Grandegger <wg@grandegger.com>
>>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>>> Cc: netdev@vger.kernel.org
>>
>> Applies to can and added stable on Cc.
>=20
> Are you absolutelly positive this doesn't break kernel ABI please ?
>=20
> I am a little worried there, since the size of can_clock and can_ctrlmo=
de
> structures differ.

struct can_clock is a u32, see [1]
struct can_ctrlmode is 2 x u32.

in libsocketcan[2] it's accessed like this:

> 	memcpy(res,
> 		RTA_DATA(can_attr[IFLA_CAN_CLOCK]),
> 		sizeof(struct can_clock));

I think it should be ok.

Marc

[1]
http://lxr.free-electrons.com/source/include/uapi/linux/can/netlink.h#L61=

[2]
http://git.pengutronix.de/?p=3Dtools/libsocketcan.git;a=3Dblob;f=3Dsrc/li=
bsocketcan.c;h=3Dc97a28cca18054c8e63326eeb5a866b79344ebe2;hb=3D4ea9ec7cf3=
7a0c52f2c39a13887aaad11042ef5c#l453

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--DA2807LQcp4ggLsn40NHkx3MQLjW9RgVu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWM3wIAAoJEP5prqPJtc/HzfsIAJ6gbahXYbStTeT3wz3boUQd
mcchkdkFIGLbGVyQ5rBHep8y/uzD7ZfxkuRCUWCUPMovLt+1SHH2gDzarjzwGh2t
lLDjvUB/BE3M9lD+tf5DU0dbHyX4ESziXU21I65RUwEnhSuPuI703dbF7BVdPchN
rqsFawwSqwblXQNadqEdZa08cSUg21KtZf3D1qcbk8SYpJeA9c6LyLcXzL7L9YaN
7A8MLn2w5TvG2s6l9DsLmeXDIPINyyrd+/F3itg+rN2BOtCJMPHEWumKSsXMw2DN
1LG1h9zhkOCtG+6aMaYRmRiTkFnZ2BZQf5+MMM+pVhREa4r/ViWHWUmXqEa9osQ=
=mqJ0
-----END PGP SIGNATURE-----

--DA2807LQcp4ggLsn40NHkx3MQLjW9RgVu--
