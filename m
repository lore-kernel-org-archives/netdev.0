From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/4] arm: mvebu: add Ethernet controllers using mvneta driver for Armada 370/XP
Date: Tue, 23 Oct 2012 18:54:59 +0200
Message-ID: <1351011300-26964-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1351011300-26964-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:39836 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933259Ab2JWQzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 12:55:23 -0400
In-Reply-To: <1351011300-26964-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Armada 370 SoC has two network units, while the Armada XP has four
network units. The first two network units are common to both the
Armada XP and Armada 370, so they are added to armada-370-xp.dtsi,
while the other two network units are specific to the Armada XP and
therefore added to armada-xp.dtsi.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-xp.dtsi |   14 ++++++++++++++
 arch/arm/boot/dts/armada-xp.dtsi     |   14 ++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
index 16cc82c..d484492 100644
--- a/arch/arm/boot/dts/armada-370-xp.dtsi
+++ b/arch/arm/boot/dts/armada-370-xp.dtsi
@@ -68,6 +68,20 @@
 			compatible = "marvell,armada-addr-decoding-controller";
 			reg = <0xd0020000 0x258>;
 		};
+
+                ethernet@d0070000 {
+                               compatible = "marvell,armada-370-neta";
+                               reg = <0xd0070000 0x2500>;
+                               interrupts = <8>;
+                               status = "disabled";
+                };
+
+                ethernet@d0074000 {
+                               compatible = "marvell,armada-370-neta";
+                               reg = <0xd0074000 0x2500>;
+                               interrupts = <10>;
+                               status = "disabled";
+                };
 	};
 };
 
diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
index 71d6b5d..c77a43e 100644
--- a/arch/arm/boot/dts/armada-xp.dtsi
+++ b/arch/arm/boot/dts/armada-xp.dtsi
@@ -51,5 +51,19 @@
 				compatible = "marvell,armada-370-xp-system-controller";
 				reg = <0xd0018200 0x500>;
 		};
+
+                ethernet@d0030000 {
+                               compatible = "marvell,armada-370-neta";
+                               reg = <0xd0030000 0x2500>;
+                               interrupts = <12>;
+                               status = "disabled";
+                };
+
+                ethernet@d0034000 {
+                               compatible = "marvell,armada-370-neta";
+                               reg = <0xd0034000 0x2500>;
+                               interrupts = <14>;
+                               status = "disabled";
+                };
 	};
 };
-- 
1.7.9.5
