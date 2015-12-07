From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Mon, 07 Dec 2015 13:56:23 +0100
Message-ID: <m3egeyct8o.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:44053 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbbLGM40 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:56:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gateworks Ventana boards seem to need "RGMII-ID" (internal delay)
PHY mode, instead of simple "RGMII", for their Marvell 88E1510
transceiver. Otherwise, the Ethernet MAC doesn't work with Marvell PHY
driver (TX doesn't seem to work correctly).

Tested on GW5400 rev. C.

This bug affects ARM Fedora 23.

Signed-off-by: Krzysztof Ha=C5=82asa <khalasa@piap.pl>

diff --git a/arch/arm/boot/dts/imx6q-gw5400-a.dts b/arch/arm/boot/dts/i=
mx6q-gw5400-a.dts
index 822ffb2..6c168dc 100644
--- a/arch/arm/boot/dts/imx6q-gw5400-a.dts
+++ b/arch/arm/boot/dts/imx6q-gw5400-a.dts
@@ -154,7 +154,7 @@
 &fec {
 	pinctrl-names =3D "default";
 	pinctrl-0 =3D <&pinctrl_enet>;
-	phy-mode =3D "rgmii";
+	phy-mode =3D "rgmii-id";
 	phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_HIGH>;
 	status =3D "okay";
 };
diff --git a/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi b/arch/arm/boot/dts/=
imx6qdl-gw51xx.dtsi
index f2867c4..90496aa 100644
--- a/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-gw51xx.dtsi
@@ -94,7 +94,7 @@
 &fec {
 	pinctrl-names =3D "default";
 	pinctrl-0 =3D <&pinctrl_enet>;
-	phy-mode =3D "rgmii";
+	phy-mode =3D "rgmii-id";
 	phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
 	status =3D "okay";
 };
diff --git a/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi b/arch/arm/boot/dts/=
imx6qdl-gw52xx.dtsi
index 4493f6e..0a6730b 100644
--- a/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-gw52xx.dtsi
@@ -154,7 +154,7 @@
 &fec {
 	pinctrl-names =3D "default";
 	pinctrl-0 =3D <&pinctrl_enet>;
-	phy-mode =3D "rgmii";
+	phy-mode =3D "rgmii-id";
 	phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
 	status =3D "okay";
 };
diff --git a/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi b/arch/arm/boot/dts/=
imx6qdl-gw53xx.dtsi
index cfad214..2c549ad 100644
--- a/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-gw53xx.dtsi
@@ -174,7 +174,7 @@
 &fec {
 	pinctrl-names =3D "default";
 	pinctrl-0 =3D <&pinctrl_enet>;
-	phy-mode =3D "rgmii";
+	phy-mode =3D "rgmii-id";
 	phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
 	status =3D "okay";
 };
diff --git a/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi b/arch/arm/boot/dts/=
imx6qdl-gw54xx.dtsi
index 535b536..b4ea087 100644
--- a/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-gw54xx.dtsi
@@ -164,7 +164,7 @@
 &fec {
 	pinctrl-names =3D "default";
 	pinctrl-0 =3D <&pinctrl_enet>;
-	phy-mode =3D "rgmii";
+	phy-mode =3D "rgmii-id";
 	phy-reset-gpios =3D <&gpio1 30 GPIO_ACTIVE_LOW>;
 	status =3D "okay";
 };

--=20
Krzysztof Halasa

Industrial Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
