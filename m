From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Mon, 26 Nov 2012 20:45:46 +1100
Message-ID: <20121126204546.ef1f1b55e903eda38a61d5d1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__26_Nov_2012_20_45_46_+1100_3k.padnfisj.dRY5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	AnilKumar Ch <anilkumar@ti.com>,
	Benoit Cousson <b-cousson@ti.com>,
	Jon Hunter <jon-hunter@ti.com>, Afzal Mohammed <afzal@ti.com>,
	"Philip, Avinash" <avinashphilip@ti.com>,
	Ajay Kumar Gupta <ajay.gupta@ti.com>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__26_Nov_2012_20_45_46_+1100_3k.padnfisj.dRY5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/boot/dts/am33xx.dtsi between commit 1a39a65cba08 ("arm/dts:
am33xx: Add CPSW and MDIO module nodes for AM33XX") from the net-next
tree and commits 059b185d5345 ("ARM: dts: AM33XX: Add D_CAN device tree
data") and 4c94ac29b5c1 ("ARM: dts: OMAP: Move interrupt-parent to the
root node to avoid duplication") (and a few others that added more later
nodes) from the arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/am33xx.dtsi
index a4615b4,20a3f29..0000000
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@@ -210,53 -222,121 +222,168 @@@
  			interrupts =3D <91>;
  		};
 =20
 +		mac: ethernet@4a100000 {
 +			compatible =3D "ti,cpsw";
 +			ti,hwmods =3D "cpgmac0";
 +			cpdma_channels =3D <8>;
 +			ale_entries =3D <1024>;
 +			bd_ram_size =3D <0x2000>;
 +			no_bd_ram =3D <0>;
 +			rx_descs =3D <64>;
 +			mac_control =3D <0x20>;
 +			slaves =3D <2>;
 +			cpts_active_slave =3D <0>;
 +			cpts_clock_mult =3D <0x80000000>;
 +			cpts_clock_shift =3D <29>;
 +			reg =3D <0x4a100000 0x800
 +			       0x4a101200 0x100>;
 +			#address-cells =3D <1>;
 +			#size-cells =3D <1>;
- 			interrupt-parent =3D <&intc>;
 +			/*
 +			 * c0_rx_thresh_pend
 +			 * c0_rx_pend
 +			 * c0_tx_pend
 +			 * c0_misc_pend
 +			 */
 +			interrupts =3D <40 41 42 43>;
 +			ranges;
 +
 +			davinci_mdio: mdio@4a101000 {
 +				compatible =3D "ti,davinci_mdio";
 +				#address-cells =3D <1>;
 +				#size-cells =3D <0>;
 +				ti,hwmods =3D "davinci_mdio";
 +				bus_freq =3D <1000000>;
 +				reg =3D <0x4a101000 0x100>;
 +			};
 +
 +			cpsw_emac0: slave@4a100200 {
 +				/* Filled in by U-Boot */
 +				mac-address =3D [ 00 00 00 00 00 00 ];
 +			};
 +
 +			cpsw_emac1: slave@4a100300 {
 +				/* Filled in by U-Boot */
 +				mac-address =3D [ 00 00 00 00 00 00 ];
 +			};
 +
 +		};
++
+ 		dcan0: d_can@481cc000 {
+ 			compatible =3D "bosch,d_can";
+ 			ti,hwmods =3D "d_can0";
+ 			reg =3D <0x481cc000 0x2000>;
+ 			interrupts =3D <52>;
+ 			status =3D "disabled";
+ 		};
+=20
+ 		dcan1: d_can@481d0000 {
+ 			compatible =3D "bosch,d_can";
+ 			ti,hwmods =3D "d_can1";
+ 			reg =3D <0x481d0000 0x2000>;
+ 			interrupts =3D <55>;
+ 			status =3D "disabled";
+ 		};
+=20
+ 		timer1: timer@44e31000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x44e31000 0x400>;
+ 			interrupts =3D <67>;
+ 			ti,hwmods =3D "timer1";
+ 			ti,timer-alwon;
+ 		};
+=20
+ 		timer2: timer@48040000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x48040000 0x400>;
+ 			interrupts =3D <68>;
+ 			ti,hwmods =3D "timer2";
+ 		};
+=20
+ 		timer3: timer@48042000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x48042000 0x400>;
+ 			interrupts =3D <69>;
+ 			ti,hwmods =3D "timer3";
+ 		};
+=20
+ 		timer4: timer@48044000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x48044000 0x400>;
+ 			interrupts =3D <92>;
+ 			ti,hwmods =3D "timer4";
+ 			ti,timer-pwm;
+ 		};
+=20
+ 		timer5: timer@48046000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x48046000 0x400>;
+ 			interrupts =3D <93>;
+ 			ti,hwmods =3D "timer5";
+ 			ti,timer-pwm;
+ 		};
+=20
+ 		timer6: timer@48048000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x48048000 0x400>;
+ 			interrupts =3D <94>;
+ 			ti,hwmods =3D "timer6";
+ 			ti,timer-pwm;
+ 		};
+=20
+ 		timer7: timer@4804a000 {
+ 			compatible =3D "ti,omap2-timer";
+ 			reg =3D <0x4804a000 0x400>;
+ 			interrupts =3D <95>;
+ 			ti,hwmods =3D "timer7";
+ 			ti,timer-pwm;
+ 		};
+=20
+ 		rtc@44e3e000 {
+ 			compatible =3D "ti,da830-rtc";
+ 			reg =3D <0x44e3e000 0x1000>;
+ 			interrupts =3D <75
+ 				      76>;
+ 			ti,hwmods =3D "rtc";
+ 		};
+=20
+ 		spi0: spi@48030000 {
+ 			compatible =3D "ti,omap4-mcspi";
+ 			#address-cells =3D <1>;
+ 			#size-cells =3D <0>;
+ 			reg =3D <0x48030000 0x400>;
+ 			interrupt =3D <65>;
+ 			ti,spi-num-cs =3D <2>;
+ 			ti,hwmods =3D "spi0";
+ 			status =3D "disabled";
+ 		};
+=20
+ 		spi1: spi@481a0000 {
+ 			compatible =3D "ti,omap4-mcspi";
+ 			#address-cells =3D <1>;
+ 			#size-cells =3D <0>;
+ 			reg =3D <0x481a0000 0x400>;
+ 			interrupt =3D <125>;
+ 			ti,spi-num-cs =3D <2>;
+ 			ti,hwmods =3D "spi1";
+ 			status =3D "disabled";
+ 		};
+=20
+ 		usb@47400000 {
+ 			compatible =3D "ti,musb-am33xx";
+ 			reg =3D <0x47400000 0x1000	/* usbss */
+ 			       0x47401000 0x800		/* musb instance 0 */
+ 			       0x47401800 0x800>;	/* musb instance 1 */
+ 			interrupts =3D <17		/* usbss */
+ 				      18		/* musb instance 0 */
+ 				      19>;		/* musb instance 1 */
+ 			multipoint =3D <1>;
+ 			num-eps =3D <16>;
+ 			ram-bits =3D <12>;
+ 			port0-mode =3D <3>;
+ 			port1-mode =3D <3>;
+ 			power =3D <250>;
+ 			ti,hwmods =3D "usb_otg_hs";
+ 		};
  	};
  };

--Signature=_Mon__26_Nov_2012_20_45_46_+1100_3k.padnfisj.dRY5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQszpKAAoJEECxmPOUX5FEu5cP/0Bmjqjt/HwwHBuMdNPhszGo
DTRLOgAlVhcnoF+lXT7kQOrR6NjdxX6DoKrS/dVcbX7bc4LgV7ZaGzi8He4DGSQj
TvM94P71q4VouL0axRpYbMXBTn4L2TkGgWCVB+RrthDZcZkMD24Seny/DlW4vfbY
piXmE+xLrVhHikR71UibqkTqUQxN8sTF6MZzTkMNJ89kREJirOcfTRBLCYok5GuF
w0PNQELVOzUvf/6PdbiYwGnPPDl52n+HwdJPt7Z8BLQJh5Gz7804eXDTMgdacy+c
nWKQqf2a6Wqpc0SYDSjp1vo1+SwWpAMo3CCrC0Z6c3C9gPaQbQqFe2qneIzKMLkX
b0YJBvl8aRE/3iQV3E02cqvOwCDrGcR3MPrgLLcalDrVBaWOGKLD7z5bx23vIcxD
jDyLtWpelaUE8hAdji1DsBxYDARJs5/OWwSFqnI9Bl/zokiJFzAqMGty4zWRnZDB
jBCkGG7yo84TwU+5ksqyexek0jOZdqmg8/NpF4OiOAkzrhYUna76L8ZKDpYqu85r
G4TNvi4aoeUDsLboCoZxIMv02gWYxyURcpB2f/A3PwnoJr8Xdwb043MuKmHQEg4T
x+qH84Wp3saAbZIwwcwZE5DVw9nZrhL5uGCgcfn8m2GdLqzHlMnEGINfdVSeGaiz
rVQv46s8AMKLj1DXH3lb
=fGAw
-----END PGP SIGNATURE-----

--Signature=_Mon__26_Nov_2012_20_45_46_+1100_3k.padnfisj.dRY5--
