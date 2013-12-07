From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Sat, 7 Dec 2013 11:27:10 +0100
Message-ID: <20131207102710.GK24519@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="x1F0m3RQhDZyj8sd"
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBX7RROKQKGQE3ZT6G5Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386350983-13281-5-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--x1F0m3RQhDZyj8sd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Chen-Yu, Mike,

On Sat, Dec 07, 2013 at 01:29:37AM +0800, Chen-Yu Tsai wrote:
> The Allwinner A20 has an ethernet controller that seems to be
> an early version of Synopsys DesignWare MAC 10/100/1000 Universal,
> which is supported by the stmmac driver.
>=20
> Allwinner's GMAC requires setting additional registers in the SoC's
> clock control unit.
>=20
> The exact version of the DWMAC IP that Allwinner uses is unknown,
> thus the exact feature set is unknown.
>=20
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> ---
>  .../bindings/net/allwinner,sun7i-gmac.txt          | 22 +++++++
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 ++++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 76 ++++++++++++++++=
++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
>  6 files changed, 117 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.t=
xt b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
> new file mode 100644
> index 0000000..271554a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
> @@ -0,0 +1,22 @@
> +* Allwinner GMAC ethernet controller
> +
> +This device is a platform glue layer for stmmac.
> +Please see stmmac.txt for the other unchanged properties.
> +
> +Required properties:
> + - compatible:  Should be "allwinner,sun7i-gmac"

Please use sun7i-a20-gmac here.

> + - reg: Address and length of register set for the device and correspond=
ing
> +   clock control
>
> +Examples:
> +
> +	gmac: ethernet@01c50000 {
> +		compatible =3D "allwinner,sun7i-gmac";
> +		reg =3D <0x01c50000 0x10000>,
> +		      <0x01c20164 0x4>;

This is actually a clock, and should probably be registered in the
common clock framework.

Mike: This small register actually is a regular muxer/divider, except
that it has some bits that are of interest to the ethernet controller
(for example to set wether it's using GMII or RGMII to communicate
with the phy), that, as far as I'm aware of, aren't really fitting
into the CCF.

Do you have some recommendation on how to proceed?

Maybe make a thin "real" clock driver in this hardware glue, that
provides !exported function to set this *GMII thing.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--x1F0m3RQhDZyj8sd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSovf+AAoJEBx+YmzsjxAgmLYP/i+4bA6/Pq8zePu32ercVzgm
XcayM1KRlainfKB0wOXDJdvUAQnVz8oBADWZgDdzVngBnl0I/dSYBaQIRSP+qymT
Hb9FVSaGu41ElmIGYY2/qZm+a1uve7JxUWFoYlBCEanhnupBsMrGS9JrzF2BGauy
4wW/Mr6VQccgd2H3dJ3EQ1Gx+8zy352Ro4/7XaAQWRWzHdv8IfVPP6qn+00irOAU
TXWmqyfbYINGYspW614II9CgWd35r108Mm2teLQZeXf+3drFzAsbJ9bykirZWldy
CG6puozWsEQdLQKKJ9WCwbyFOAXm7nhRRa0ZpnRRlkHxTPf3Tr3AKr2VKe7nqCd+
oo1larxPvveFw1uPYEgnQ74PSAj6WImrt/803RDb6uyj4oPaGoZkxg7pG7bw19mC
bSQXA/ZUc3e3gqe+ZP5bnAh2NnyaRNJEBr1hcPfa+A2J834aVzxvT2m8W4OjoiZb
XE3m0cnp6WusKQlZfD+kg+8oCY8B2TVV+MQ5SfF6zGGhPjq2ZTzx6xOdQNqNnIE6
1c7XaiSHLmvvTiec0S5Xuh7Z3Tkaz+3xdujV1sjN/4xW7iK6O2E1YwcI79uF7sPe
CyenDvQ8NVvMyvCjNbJjIueIn81JGr0J1JaTCLUh79hB4qwmzi1Zc8VHRyC7Huii
U9dh4gNPJfUW3/dVISU+
=M5vb
-----END PGP SIGNATURE-----

--x1F0m3RQhDZyj8sd--
