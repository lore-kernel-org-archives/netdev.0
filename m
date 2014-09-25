From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Thu, 25 Sep 2014 12:58:57 +1000
Message-ID: <20140925125857.0516ceab@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/l7NdUEnl4WNLJKabrlsjS9D"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Romain Perier <romain.perier@gmail.com>,
	Heiko Stuebner <heiko@sntech.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/l7NdUEnl4WNLJKabrlsjS9D
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
arch/arm/boot/dts/rk3188.dtsi and arch/arm/boot/dts/rk3xxx.dtsi between
commits fd14e6f9b461 ("ARM: dts: rockchip: add dwc2 controllers for
rk3066 and rk3188") and 4ff4ae1258a9 ("ARM: dts: rockchip: add emmc
nodes for rk3066 and rk3188") from the arm-soc tree and commit
18ec91e1947f ("ARM: dts: Add emac nodes to the rk3188 device tree")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/rk3188.dtsi
index 82732f5249b2,7f25bc51f2ee..000000000000
--- a/arch/arm/boot/dts/rk3188.dtsi
+++ b/arch/arm/boot/dts/rk3188.dtsi
@@@ -147,27 -147,24 +147,45 @@@
  			bias-disable;
  		};
 =20
 +		emmc {
 +			emmc_clk: emmc-clk {
 +				rockchip,pins =3D <RK_GPIO0 24 RK_FUNC_2 &pcfg_pull_none>;
 +			};
 +
 +			emmc_cmd: emmc-cmd {
 +				rockchip,pins =3D <RK_GPIO0 26 RK_FUNC_2 &pcfg_pull_up>;
 +			};
 +
 +			emmc_rst: emmc-rst {
 +				rockchip,pins =3D <RK_GPIO0 27 RK_FUNC_2 &pcfg_pull_none>;
 +			};
 +
 +			/*
 +			 * The data pins are shared between nandc and emmc and
 +			 * not accessible through pinctrl. Also they should've
 +			 * been already set correctly by firmware, as
 +			 * flash/emmc is the boot-device.
 +			 */
 +		};
 +
+ 		emac {
+ 			emac_xfer: emac-xfer {
+ 				rockchip,pins =3D <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, /* tx_en */
+ 						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, /* txd1 */
+ 						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, /* txd0 */
+ 						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, /* rxd0 */
+ 						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, /* rxd1 */
+ 						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, /* mac_clk */
+ 						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, /* rx_err */
+ 						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; /* crs_dvalid */
+ 			};
+=20
+ 			emac_mdio: emac-mdio {
+ 				rockchip,pins =3D <RK_GPIO3 24 RK_FUNC_2 &pcfg_pull_none>,
+ 						<RK_GPIO3 25 RK_FUNC_2 &pcfg_pull_none>;
+ 			};
+ 		};
+=20
  		i2c0 {
  			i2c0_xfer: i2c0-xfer {
  				rockchip,pins =3D <RK_GPIO1 24 RK_FUNC_1 &pcfg_pull_none>,
diff --cc arch/arm/boot/dts/rk3xxx.dtsi
index 7332d12eb565,208b1df6bcb0..000000000000
--- a/arch/arm/boot/dts/rk3xxx.dtsi
+++ b/arch/arm/boot/dts/rk3xxx.dtsi
@@@ -134,24 -91,23 +134,41 @@@
  		status =3D "disabled";
  	};
 =20
 +	usb_otg: usb@10180000 {
 +		compatible =3D "rockchip,rk3066-usb", "snps,dwc2";
 +		reg =3D <0x10180000 0x40000>;
 +		interrupts =3D <GIC_SPI 16 IRQ_TYPE_LEVEL_HIGH>;
 +		clocks =3D <&cru HCLK_OTG0>;
 +		clock-names =3D "otg";
 +		status =3D "disabled";
 +	};
 +
 +	usb_host: usb@101c0000 {
 +		compatible =3D "snps,dwc2";
 +		reg =3D <0x101c0000 0x40000>;
 +		interrupts =3D <GIC_SPI 17 IRQ_TYPE_LEVEL_HIGH>;
 +		clocks =3D <&cru HCLK_OTG1>;
 +		clock-names =3D "otg";
 +		status =3D "disabled";
 +	};
 +
+ 	emac: ethernet@10204000 {
+ 		compatible =3D "snps,arc-emac";
+ 		reg =3D <0x10204000 0x3c>;
+ 		interrupts =3D <GIC_SPI 19 IRQ_TYPE_LEVEL_HIGH>;
+ 		#address-cells =3D <1>;
+ 		#size-cells =3D <0>;
+=20
+ 		rockchip,grf =3D <&grf>;
+=20
+ 		clocks =3D <&cru HCLK_EMAC>, <&cru SCLK_MAC>;
+ 		clock-names =3D "hclk", "macref";
+ 		max-speed =3D <100>;
+ 		phy-mode =3D "rmii";
+=20
+ 		status =3D "disabled";
+ 	};
+=20
  	mmc0: dwmmc@10214000 {
  		compatible =3D "rockchip,rk2928-dw-mshc";
  		reg =3D <0x10214000 0x1000>;

--Sig_/l7NdUEnl4WNLJKabrlsjS9D
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUI4T3AAoJEMDTa8Ir7ZwVSJsP/0990/Y9OVkY8nWp0DopSpbl
jPsb4jEZC2HgBXRH1Lh6envvWXB9kF9rGYys8vNUubsOQRBamg5UWWT9wDh8NZhY
V/G615z+07sz7ylRt3CwftuiMEzEEDkgUJclZLHv8Jcpff/Yxjcbsf3utW+cMJM8
+i2Bt9/zMNy+sZ13OXYrgL7r3YvhS890lvgiyss978VyBC8xB6+EjUQHRtJOh1Y3
kflRVtAbEepzNfbouDKvceXwpegIerowJZmzU+HFWSy2lh/v3h9sxahxmWemBXy1
uFKClD02Emy488l/zgWdZ6Q2H59yK6DoPygrc01jG/Mm59+6JSmvyKFovyQEMBu8
EKDAGPnUia0sDAgBO82QsXm2YE5J1Q3j0iN03+at3BAfCjuCEDQiY2BzMH3Hdoio
X0t3AaYcbzFLdjXZ8OedVw+6h+8snqbULGwSaYZB4G25lgsyljl3CrLjYPgghIyR
YtH81Irzh1HK80KzIminFPcUF+0iN9ud6UtePAHWaiRpq/7qss3Pow2oVTG0otcQ
aN7s3ITMD1u7z22CewRocL9n1jS8NUnNjVN3MMdwi7jVsN5s903nTdUyQYLVrk1t
n8NIZ+fgJ6RWq66+IzgdkPvBwwh7BiFh1TvsrwENeC8h6is7mPjeUpqRs99BA+AB
Hllu+SueqaOmd/cm148H
=8A4x
-----END PGP SIGNATURE-----

--Sig_/l7NdUEnl4WNLJKabrlsjS9D--
