From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 5/7] arm: mvebu: enable Ethernet controllers on Armada 370/XP eval boards
Date: Mon, 12 Nov 2012 18:07:08 +0100
Message-ID: <1352740030-12801-6-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([88.190.12.23]:40153 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263Ab2KLRIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:08:12 -0500
In-Reply-To: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the two network interfaces of the Armada 370
official Marvell evaluation platform, and the four network interfaces
of the Armada XP official Marvell evaluation platform.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-db.dts |   23 +++++++++++++++++++
 arch/arm/boot/dts/armada-xp-db.dts  |   43 +++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-db.dts b/arch/arm/boot/dts/armada-370-db.dts
index fffd5c2..76362f7 100644
--- a/arch/arm/boot/dts/armada-370-db.dts
+++ b/arch/arm/boot/dts/armada-370-db.dts
@@ -38,5 +38,28 @@
 			clock-frequency = <600000000>;
 			status = "okay";
 		};
+
+		mdio {
+			phy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			phy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+		};
+
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
diff --git a/arch/arm/boot/dts/armada-xp-db.dts b/arch/arm/boot/dts/armada-xp-db.dts
index b1fc728..b614bd0 100644
--- a/arch/arm/boot/dts/armada-xp-db.dts
+++ b/arch/arm/boot/dts/armada-xp-db.dts
@@ -46,5 +46,48 @@
 			clock-frequency = <250000000>;
 			status = "okay";
 		};
+
+		mdio {
+			phy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+
+			phy1: ethernet-phy@1 {
+				reg = <1>;
+			};
+
+			phy2: ethernet-phy@2 {
+				reg = <25>;
+			};
+
+			phy3: ethernet-phy@3 {
+				reg = <27>;
+			};
+		};
+
+		ethernet@d0070000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy0>;
+			phy-mode = "rgmii-id";
+		};
+		ethernet@d0074000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy1>;
+			phy-mode = "rgmii-id";
+		};
+		ethernet@d0030000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy2>;
+			phy-mode = "sgmii";
+		};
+		ethernet@d0034000 {
+			clock-frequency = <250000000>;
+			status = "okay";
+			phy = <&phy3>;
+			phy-mode = "sgmii";
+		};
 	};
 };
-- 
1.7.9.5
