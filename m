From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Mon, 17 Jun 2013 16:43:14 +1000
Message-ID: <20130617164314.16ac062ac1d9f9a880aa1e07@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Jun_2013_16_43_14_+1000_1uTom2tmFfVdO9eu"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	ergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Jun_2013_16_43_14_+1000_1uTom2tmFfVdO9eu
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/mach-shmobile/clock-r8a7778.c between commit 589ebdef7e31
("sh_eth: get R8A777x support out of #ifdef") from the net-next tree and
commits 1189b1cb50a0 ("ARM: shmobile: r8a7778: add SDHI clock support")
and 02474a41e618 ("ARM: shmobile: r8a7778: add USB support") from the
arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/mach-shmobile/clock-r8a7778.c
index 9614b07,53798e5..0000000
--- a/arch/arm/mach-shmobile/clock-r8a7778.c
+++ b/arch/arm/mach-shmobile/clock-r8a7778.c
@@@ -76,8 -136,22 +136,22 @@@ static struct clk mstp_clks[MSTP_NR] =3D=20
  };
 =20
  static struct clk_lookup lookups[] =3D {
+ 	/* main */
+ 	CLKDEV_CON_ID("shyway_clk",	&s_clk),
+ 	CLKDEV_CON_ID("peripheral_clk",	&p_clk),
+=20
  	/* MSTP32 clocks */
+ 	CLKDEV_DEV_ID("sh_mmcif", &mstp_clks[MSTP331]), /* MMC */
+ 	CLKDEV_DEV_ID("sh_mobile_sdhi.0", &mstp_clks[MSTP323]), /* SDHI0 */
+ 	CLKDEV_DEV_ID("sh_mobile_sdhi.1", &mstp_clks[MSTP322]), /* SDHI1 */
+ 	CLKDEV_DEV_ID("sh_mobile_sdhi.2", &mstp_clks[MSTP321]), /* SDHI2 */
 -	CLKDEV_DEV_ID("sh-eth",	&mstp_clks[MSTP114]), /* Ether */
 +	CLKDEV_DEV_ID("r8a777x-ether", &mstp_clks[MSTP114]), /* Ether */
+ 	CLKDEV_DEV_ID("ehci-platform", &mstp_clks[MSTP100]), /* USB EHCI port0/1=
 */
+ 	CLKDEV_DEV_ID("ohci-platform", &mstp_clks[MSTP100]), /* USB OHCI port0/1=
 */
+ 	CLKDEV_DEV_ID("i2c-rcar.0", &mstp_clks[MSTP030]), /* I2C0 */
+ 	CLKDEV_DEV_ID("i2c-rcar.1", &mstp_clks[MSTP029]), /* I2C1 */
+ 	CLKDEV_DEV_ID("i2c-rcar.2", &mstp_clks[MSTP028]), /* I2C2 */
+ 	CLKDEV_DEV_ID("i2c-rcar.3", &mstp_clks[MSTP027]), /* I2C3 */
  	CLKDEV_DEV_ID("sh-sci.0", &mstp_clks[MSTP026]), /* SCIF0 */
  	CLKDEV_DEV_ID("sh-sci.1", &mstp_clks[MSTP025]), /* SCIF1 */
  	CLKDEV_DEV_ID("sh-sci.2", &mstp_clks[MSTP024]), /* SCIF2 */

--Signature=_Mon__17_Jun_2013_16_43_14_+1000_1uTom2tmFfVdO9eu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRvrACAAoJEECxmPOUX5FEeQoP/0AXm7ldR9plgi5xkGjJI6lR
i9E2zhF+Fvb/uEZWWSZAlvsTNlzUeCw15AKLEfISzv5PEmgG3BAoK/rYjFGWUQsj
PyofwCZkmLOUcE775+d8Qqfzd/+tP2zWPqN42ftMqum9HznNccStgBDai0N8dqWJ
OWxKIiXj+/eTAxtYWq52u5no5jamlUASKeqbljpBcLSO4zfzRmuJSQeEg+OFfeth
yj9vc9HMrQ3/v7V4WX0+uiGXI7qwZP3sPJFAB5qCqndcvpg7vKb78IGod/Tv1HPA
apywmd+rLSqS7osCGgQa9Y0iiXdC3KJSHnunwywS5pwDAjv13m9Z/5cdxMnRFvCn
PmN7T+QhXZJDiuQlweBVgZVJ1tzF7yxHikxISSGYz8JPjV4VZ2Vs8CS93YSglvfA
jhROW+7LFR7IX0tenzMgXx1qS+GMD+MdvqxjepizX7CYLBNY9yULJLbJk/4tJGp3
VpEZFZMbaO2xxrqVuceJsX/tPf3LlJKHvsWlzSefFB5SUiIplZ/uBqpsyo12MUL7
0rzdJ72vedvdcv5uiZ/3yJZsIdSy+J4U6UftJyKFz196cxZi+ha3vcjlbrjIFXOs
vka5r54MF9tK6yTPfq/QGd+iQ3ujS1cvVJ02HoZ1+tfZIF1vrpJwCoVrQJd1FI9m
5iHJMHOx7IzrZhKRij8E
=BKJP
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Jun_2013_16_43_14_+1000_1uTom2tmFfVdO9eu--
