From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 3/4] arm: mvebu: add Ethernet controllers using mvneta driver for Armada 370/XP
Date: Thu, 11 Oct 2012 17:28:01 +0200
Message-ID: <1349969282-12676-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35254 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908Ab2JKP2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:28:49 -0400
In-Reply-To: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Armada 370 SoC has two network units, while the Armada XP has four
network units. The first two network units are common to both the
Armada XP and Armada 370, so they are added to armada-370-xp.dtsi,
while the other two network units are specific to the Armada XP and
therefore added to armada-xp.dtsi.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-xp.dtsi |   16 ++++++++++++++++
 arch/arm/boot/dts/armada-xp.dtsi     |   16 ++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-xp.dtsi b/arch/arm/boot/dts/armada-370-xp.dtsi
index 6b6b932..52af710 100644
--- a/arch/arm/boot/dts/armada-370-xp.dtsi
+++ b/arch/arm/boot/dts/armada-370-xp.dtsi
@@ -63,6 +63,22 @@
 			       reg = <0xd0020300 0x30>;
 			       interrupts = <37>, <38>, <39>, <40>;
 		};
+
+                eth@d0070000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0070000 0x2500>;
+                               interrupts = <8>;
+                               device_type = "network";
+                               status = "disabled";
+                };
+
+                eth@d0074000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0074000 0x2500>;
+                               interrupts = <10>;
+                               device_type = "network";
+                               status = "disabled";
+                };
 	};
 };
 
diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
index 71d6b5d..59167dc 100644
--- a/arch/arm/boot/dts/armada-xp.dtsi
+++ b/arch/arm/boot/dts/armada-xp.dtsi
@@ -51,5 +51,21 @@
 				compatible = "marvell,armada-370-xp-system-controller";
 				reg = <0xd0018200 0x500>;
 		};
+
+                eth@d0030000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0030000 0x2500>;
+                               interrupts = <12>;
+                               device_type = "network";
+                               status = "disabled";
+                };
+
+                eth@d0034000 {
+                               compatible = "marvell,neta";
+                               reg = <0xd0034000 0x2500>;
+                               interrupts = <14>;
+                               device_type = "network";
+                               status = "disabled";
+                };
 	};
 };
-- 
1.7.9.5
