From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH v2 3/3] arm64: dts: marvell: Add ethernet switch definition for the ESPRESSObin
Date: Tue, 20 Dec 2016 09:51:38 +0100
Message-ID: <20161220085138.3998-4-romain.perier@free-electrons.com>
References: <20161220085138.3998-1-romain.perier@free-electrons.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Romain Perier <romain.perier@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:32855 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754643AbcLTIwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 03:52:20 -0500
In-Reply-To: <20161220085138.3998-1-romain.perier@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This defines and enables the Marvell ethernet switch MVE886341 on the
Marvell ESPRESSObin board.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
---

Changes in v2:
 - EXPRESSObin -> ESPRESSObin
 - phy nodes definition must contain the internal bus address after the @

 .../boot/dts/marvell/armada-3720-espressobin.dts   | 67 ++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts b/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
index 83178d9..9582661 100644
--- a/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
+++ b/arch/arm64/boot/dts/marvell/armada-3720-espressobin.dts
@@ -80,3 +80,70 @@
 &usb3 {
 	status = "okay";
 };
+
+&mdio {
+	switch0: switch0@0 {
+		compatible = "marvell,mv88e6085";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <1>;
+
+		dsa,member = <0 0>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			port@0 {
+				reg = <0>;
+				label = "cpu";
+				ethernet = <&eth0>;
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "wan";
+				phy-handle = <&switch0phy0>;
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan0";
+				phy-handle = <&switch0phy1>;
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "lan1";
+				phy-handle = <&switch0phy2>;
+			};
+
+		};
+
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <1>;
+
+			switch0phy0: switch0phy0@11 {
+				reg = <0x11>;
+			};
+			switch0phy1: switch0phy1@12 {
+				reg = <0x12>;
+			};
+			switch0phy2: switch0phy2@13 {
+				reg = <0x13>;
+			};
+		};
+	};
+};
+
+&eth0 {
+	phy-mode = "rgmii-id";
+	status = "okay";
+
+	fixed-link {
+		speed = <1000>;
+		full-duplex;
+	};
+};
-- 
2.9.3
