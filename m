From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: xilinx: use readl/writel instead of
 ioread/iowrite
Date: Thu, 22 Oct 2015 10:21:58 +0200
Message-ID: <56289CA6.1060809@pengutronix.de>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
 <4061693.oBld7AKBIp@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ICgIedgXSlQiUJe8nlqTNpLTb9SJkhO1m"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	anirudh@xilinx.com, wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appanad@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4061693.oBld7AKBIp@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ICgIedgXSlQiUJe8nlqTNpLTb9SJkhO1m
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/22/2015 10:14 AM, Arnd Bergmann wrote:
> On Thursday 22 October 2015 10:16:02 Kedareswara rao Appana wrote:
>> The driver only supports memory-mapped I/O [by ioremap()],
>> so readl/writel is actually the right thing to do, IMO.
>> During the validation of this driver or IP on ARM 64-bit processor
>> while sending lot of packets observed that the tx packet drop with iow=
rite
>> Putting the barriers for each tx fifo register write fixes this issue
>> Instead of barriers using writel also fixed this issue.
>>
>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>=20
> The two should really do the same thing: iowrite32() is just a static i=
nline
> calling writel() on both ARM32 and ARM64. On which kernel version did y=
ou
> observe the difference? It's possible that an older version used
> CONFIG_GENERIC_IOMAP, which made this slightly more expensive.
>=20
> If there are barriers that you want to get rid of for performance reaso=
ns,
> you should use writel_relaxed(), but be careful to synchronize them cor=
rectly
> with regard to DMA. It should be fine in this driver, as it does not
> perform any DMA, but be aware that there is no big-endian version of
> writel_relaxed() at the moment.

We don't have DMA in CAN drivers, but usually a certain write triggers
sending. Do we need a barrier before triggering the sending?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ICgIedgXSlQiUJe8nlqTNpLTb9SJkhO1m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWKJypAAoJEP5prqPJtc/HxDUH/2hcfIW1UucgyZbBuoaVEmxb
n6VHHI1k6HTh1wEEI79yZD0p9tDXqD/JSxXcXyeLN0gqikuxT1oTnKQm0RO/lV0+
PqTfbE9Km2t34dcwt3QN+B7uJY85A+ze8+yStWjHsykoZQ3U4AWBQ3EsBSVdaZqD
7jyLgZREnyudNMxbLGt7TeV3VfGNuCRfiDsABtqwFWnRF1+HImqCYcnONBuy2mnz
Dah78qS8JVp4mLOYF8bP3IHgYebGyKF6zMXUczna8mRrTHhX0eHS7ir9O9VrgoDp
lr8fWql5b+cs3nTjCq/ZpKvZR0l3CZm5R5/Wqo+C6O7kKE+9PAj7lm8k+IXGuUM=
=bfxn
-----END PGP SIGNATURE-----

--ICgIedgXSlQiUJe8nlqTNpLTb9SJkhO1m--
