From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH v3 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Wed, 01 Apr 2015 11:07:33 +0200
Message-ID: <551BB555.7030808@pengutronix.de>
References: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net> <1427867429-3909-2-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="nQK8KglDtWRQ0OOgCdTXCQEKl0GgiSvLJ"
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1427867429-3909-2-git-send-email-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nQK8KglDtWRQ0OOgCdTXCQEKl0GgiSvLJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/01/2015 07:50 AM, Oliver Hartkopp wrote:
> The CAN_RAW socket can set multiple CAN identifier specific filters tha=
t lead
> to multiple filters in the af_can.c filter processing. These filters ar=
e
> indenpendent from each other which leads to logical OR'ed filters when =
applied.
>=20
> This patch makes sure that every CAN frame which is filtered for a spec=
ific
> socket is only delivered once to the user space. This is independent fr=
om the
> number of matching CAN filters of this socket.
>=20
> As the raw_rcv() function is executed from NET_RX softirq the introduce=
d
> variables are implemented as per-CPU variables to avoid extensive locki=
ng at
> CAN frame reception time.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  net/can/raw.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>=20
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 00c13ef..8c75446 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -74,6 +74,11 @@ MODULE_ALIAS("can-proto-1");
>   * storing the single filter in dfilter, to avoid using dynamic memory=
=2E
>   */
> =20
> +struct uniqframe {
> +	const struct sk_buff *skb;
> +	ktime_t tstamp;
> +};

Nitpick: as ktime_t is always a 64 bit value, I think putting it first
might provide better alignment.

No need to repost, I'll change this while applying, if you're okay with
this.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--nQK8KglDtWRQ0OOgCdTXCQEKl0GgiSvLJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVG7VYAAoJECte4hHFiupUj1sQAIPG2+4EieP0RYpgl++BnHNb
26rV07VldX0mxngwg67gob+9OOVNEHjrKfdDiBb4fdv/sIs5UujSSQt8qwm9dfdC
3wX/aI2DIehjOpE3eZd8a4tN3cgXBLo0avKpZF/zOXlaqdDbqxuFKPI8PSkq1ANw
IqwdB/qyfLR7FT8Qu78cEbHt/KGrNrsEoZyZ8wYhQ2vZhY0vibEP/z0SPpJ4lH1J
ugAcgF3Thi6I/f0s/TNMmaHLceSzJkXPnLWHpRQDrVNOQl8WxTZ366z/2XXJg8yj
/1V5Xdg+2EIsoyO7z+GsFJFIaErMmqo0mD44vwxnVr3fjbn0jDjznvRM/ApN8b6I
yTELuOsiI4Jyr78d1V+S0hMN3dbgUsBxitF3TsVn9qF0FQXI1gzgk7C2OZlHvf1m
QyX6xbiXvi9qp9glVLS6U+ZJg12ber/rYaF3i729x1EcI3FKQv60LpjGAEUp11xy
WO3ssN1WsJalxM4QxaE4QQGv/9wAPNx6bDHfKGODjVJ+0hrk9ezbY7Zyy7LI189v
6aOOZkGlDh5qY/3ug83PWVV2nBKDv4Mniasp879J7IteWW7+VarvBYgclkm4fO2E
Qu+xLyuDkj039FcAwbXYvUWpHssra/OPehNLl/icm93+suKvHrpXdyh8AU92JPti
yQBK3DdnDFFDJJAZ1K+n
=UebI
-----END PGP SIGNATURE-----

--nQK8KglDtWRQ0OOgCdTXCQEKl0GgiSvLJ--
