From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 6/9] ARM: berlin: Add BG2 ethernet DT nodes
Date: Wed, 22 Oct 2014 20:26:49 +0200
Message-ID: <1414002412-13615-7-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1414002412-13615-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1414002412-13615-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marvell BG2 has two fast ethernet controllers with internal PHY,
add the corresponding nodes to SoC dtsi.

Tested-by: Antoine T=C3=A9nart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changelog:
v1->v2:
- move phy-connection-type to controller node instead of PHY node
  (Reported by Sergei Shtylyov)

Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Antoine T=C3=A9nart" <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/arm/boot/dts/berlin2.dtsi | 36 ++++++++++++++++++++++++++++++++++=
++
 1 file changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/berlin2.dtsi b/arch/arm/boot/dts/berlin2=
=2Edtsi
index 9d7c810ebd0b..dc0227dfc691 100644
--- a/arch/arm/boot/dts/berlin2.dtsi
+++ b/arch/arm/boot/dts/berlin2.dtsi
@@ -79,11 +79,47 @@
 			clocks =3D <&chip CLKID_TWD>;
 		};
=20
+		eth1: ethernet@b90000 {
+			compatible =3D "marvell,pxa168-eth";
+			reg =3D <0xb90000 0x10000>;
+			clocks =3D <&chip CLKID_GETH1>;
+			interrupts =3D <GIC_SPI 24 IRQ_TYPE_LEVEL_HIGH>;
+			/* set by bootloader */
+			local-mac-address =3D [00 00 00 00 00 00];
+			#address-cells =3D <1>;
+			#size-cells =3D <0>;
+			phy-connection-type =3D "mii";
+			phy-handle =3D <&ethphy1>;
+			status =3D "disabled";
+
+			ethphy1: ethernet-phy@0 {
+				reg =3D <0>;
+			};
+		};
+
 		cpu-ctrl@dd0000 {
 			compatible =3D "marvell,berlin-cpu-ctrl";
 			reg =3D <0xdd0000 0x10000>;
 		};
=20
+		eth0: ethernet@e50000 {
+			compatible =3D "marvell,pxa168-eth";
+			reg =3D <0xe50000 0x10000>;
+			clocks =3D <&chip CLKID_GETH0>;
+			interrupts =3D <GIC_SPI 8 IRQ_TYPE_LEVEL_HIGH>;
+			/* set by bootloader */
+			local-mac-address =3D [00 00 00 00 00 00];
+			#address-cells =3D <1>;
+			#size-cells =3D <0>;
+			phy-connection-type =3D "mii";
+			phy-handle =3D <&ethphy0>;
+			status =3D "disabled";
+
+			ethphy0: ethernet-phy@0 {
+				reg =3D <0>;
+			};
+		};
+
 		apb@e80000 {
 			compatible =3D "simple-bus";
 			#address-cells =3D <1>;
--=20
2.1.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
