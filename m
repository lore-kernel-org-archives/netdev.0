From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 7/7] arm: mvebu: enable Ethernet controllers on Mirabox platform
Date: Mon, 12 Nov 2012 18:07:10 +0100
Message-ID: <1352740030-12801-8-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:40126 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263Ab2KLRII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:08:08 -0500
In-Reply-To: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Globalscale Mirabox platform has two Ethernet interfaces,
connected to the SoC with a RGMII interface.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-mirabox.dts |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-mirabox.dts b/arch/arm/boot/dts/armada-370-mirabox.dts
index 9eef8dd..8554dbe 100644
--- a/arch/arm/boot/dts/armada-370-mirabox.dts
+++ b/arch/arm/boot/dts/armada-370-mirabox.dts
@@ -33,5 +33,26 @@
 			clock-frequency = <600000000>;
 			status = "okay";
 		};
+		mdio {
+			phy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			phy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
+		ethernet@d0070000 {
+			clock-frequency = <200000000>;
+			status = "okay";
+			phy = <&phy0>;
+			phy-mode = "rgmii-id";
+		};
+		ethernet@d0074000 {
+			clock-frequency = <200000000>;
+			status = "okay";
+			phy = <&phy1>;
+			phy-mode = "rgmii-id";
+		};
 	};
 };
-- 
1.7.9.5
