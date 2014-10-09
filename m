From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFT 7/8] ARM: berlin: Add BG2CD ethernet DT nodes
Date: Thu,  9 Oct 2014 14:39:05 +0200
Message-ID: <1412858346-11334-8-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33673 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbaJIMjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 08:39:23 -0400
In-Reply-To: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell BG2CD has two fast ethernet controllers with internal PHY,
add the corresponding nodes to SoC dtsi.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: devicetree@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/boot/dts/berlin2cd.dtsi | 36 ++++++++++++++++++++++++++++++++=
++++
 1 file changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/berlin2cd.dtsi b/arch/arm/boot/dts/berli=
n2cd.dtsi
index 68f7032b4686..ee3a22ad4b5f 100644
--- a/arch/arm/boot/dts/berlin2cd.dtsi
+++ b/arch/arm/boot/dts/berlin2cd.dtsi
@@ -66,6 +66,42 @@
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
+			phy-handle =3D <&ethphy1>;
+			status =3D "disabled";
+
+			ethphy1: ethernet-phy@0 {
+				phy-connection-type =3D "mii";
+				reg =3D <0>;
+			};
+		};
+
+		eth0: ethernet@e50000 {
+			compatible =3D "marvell,pxa168-eth";
+			reg =3D <0xe50000 0x10000>;
+			clocks =3D <&chip CLKID_GETH0>;
+			interrupts =3D <GIC_SPI 8 IRQ_TYPE_LEVEL_HIGH>;
+			/* set by bootloader */
+			local-mac-address =3D [00 00 00 00 00 00];
+			#address-cells =3D <1>;
+			#size-cells =3D <0>;
+			phy-handle =3D <&ethphy0>;
+			status =3D "disabled";
+
+			ethphy0: ethernet-phy@0 {
+				phy-connection-type =3D "mii";
+				reg =3D <0>;
+			};
+		};
+
 		apb@e80000 {
 			compatible =3D "simple-bus";
 			#address-cells =3D <1>;
--=20
2.1.1
