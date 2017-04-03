From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v3 12/20] ARM: dts: sun8i: Enable dwmac-sun8i on the
 Orange Pi plus
Date: Mon, 3 Apr 2017 13:37:21 +0200
Message-ID: <20170403113721.nijh2uwgepfkrpm4@lukather>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-13-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8148602171014611321=="
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, alexandre.torgue@st.com,
 catalin.marinas@arm.com, will.deacon@arm.com, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 netdev@vger.kernel.org, peppe.cavallaro@st.com,
 linux-arm-kernel@lists.infradead.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170403091444.29876-13-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============8148602171014611321==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="4ci5l4fbjve5uyrx"
Content-Disposition: inline


--4ci5l4fbjve5uyrx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 03, 2017 at 11:14:36AM +0200, Corentin Labbe wrote:
> The dwmac-sun8i hardware is present on the Orange PI plus.
> It uses an external PHY rtl8211e via RGMII.
>=20
> This patch create the needed regulator, emac and phy nodes.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts | 36 ++++++++++++++++++++++=
++++++
>  1 file changed, 36 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts b/arch/arm/boot=
/dts/sun8i-h3-orangepi-plus.dts
> index 8c40ab7..6852006 100644
> --- a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
> +++ b/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
> @@ -58,6 +58,18 @@
>  		enable-active-high;
>  		gpio =3D <&pio 6 11 GPIO_ACTIVE_HIGH>;
>  	};
> +
> +	reg_gmac_3v3: gmac-3v3 {
> +		compatible =3D "regulator-fixed";
> +		pinctrl-names =3D "default";
> +		pinctrl-0 =3D <&gmac_power_pin_orangepi>;
> +		regulator-name =3D "gmac-3v3";
> +		regulator-min-microvolt =3D <3300000>;
> +		regulator-max-microvolt =3D <3300000>;
> +		startup-delay-us =3D <100000>;
> +		enable-active-high;
> +		gpio =3D <&pio 3 6 GPIO_ACTIVE_HIGH>;
> +	};
>  };
> =20
>  &ehci3 {
> @@ -86,8 +98,32 @@
>  		pins =3D "PG11";
>  		function =3D "gpio_out";
>  	};
> +
> +	gmac_power_pin_orangepi: gmac_power_pin@0 {
> +		pins =3D "PD6";
> +		function =3D "gpio_out";
> +		drive-strength =3D <10>;
> +	};

This is not needed, and will even harm the fixing of a bug that will
require to remove all the GPIO nodes. It works fine without it, please
remove it.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--4ci5l4fbjve5uyrx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJY4jPtAAoJEBx+YmzsjxAgEjYQAKKcmP5Fs5K6+hCN2dntY8PQ
mZMN2gIiNoTxOsCSew/1MfHlbcqJTUgV5SHC5kvNi+ePiLfiWeHKo4qqyJRo7BXt
MOwuulhsFaFYShSt0CG+LQYcUwA1GhhDoAUomR0mqa/GzbGr5OvgxvUhCoiFNJR4
WmpEkIfeML8wxLsQmsqtzKOvE1gS2o0W1FEk+i3vbxyMoz+oArAb1ziRlHm/5VHC
Unp94rthG5W9YBEw2FNcA7+Vwhl9vHNCEC7huqAJN64ATdsvVwKRyAaXs/a1xpt7
9miFEOUClifY8odKcablORxJ+4JR/v8NnqZ+FxFfC5khbBEbtXnh4We12qgvHgbM
n7t1CbjsJ2+6aGlJGBYtBj7JB86QgnZixHI88RyJmCxTU2iZimpMc/YmoUIUiJgr
srCUG7mWn/pG1Y7t443BjBv2/QuVBaGzd5q5cuFdv3L/iavrQTQDIhC/J/9a//t2
3BcWoRYLiM5BP3OntdRWfWGJin0MpqveVxg22dcKrOumNyBGcW4fZ3A81K7YiUlu
Z4WJVYpskJpoT0YNvSpQ73/REyIg58S01tzdEuDV33PNHLjKkBqVtzBWqrw0XmbU
FWeei2YLcIYaT67Ni/JB5lC1mhVBJeU1ZbpenyYMRlIvTt6Z6Lhs6IzChJQbO194
S5Sq9AU9oqSJV3gA49gF
=V2KQ
-----END PGP SIGNATURE-----

--4ci5l4fbjve5uyrx--


--===============8148602171014611321==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============8148602171014611321==--
