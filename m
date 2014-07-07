From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 3/4] ARM: mvebu: Enable the network controller in Armada 375 DB board
Date: Mon,  7 Jul 2014 15:45:50 -0300
Message-ID: <1404758751-2346-4-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1404758751-2346-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>, romieu@fr.zoreil.com,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:59786 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752250AbaGGSrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 14:47:07 -0400
In-Reply-To: <1404758751-2346-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit enables the network controller in the Armada 375 DB board,
and configures the two available ethernet interfaces.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 arch/arm/boot/dts/armada-375-db.dts | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/arch/arm/boot/dts/armada-375-db.dts b/arch/arm/boot/dts/armada-375-db.dts
index 1e2919d..929ae00 100644
--- a/arch/arm/boot/dts/armada-375-db.dts
+++ b/arch/arm/boot/dts/armada-375-db.dts
@@ -123,6 +123,32 @@
 				cd-gpios = <&gpio1 12 GPIO_ACTIVE_HIGH>;
 				wp-gpios = <&gpio1 13 GPIO_ACTIVE_HIGH>;
 			};
+
+			mdio {
+				phy0: ethernet-phy@0 {
+					reg = <0>;
+				};
+
+				phy3: ethernet-phy@3 {
+					reg = <3>;
+				};
+			};
+
+			ethernet@f0000 {
+				status = "okay";
+
+				eth0@c4000 {
+					status = "okay";
+					phy = <&phy0>;
+					phy-mode = "rgmii-id";
+				};
+
+				eth1@c5000 {
+					status = "okay";
+					phy = <&phy3>;
+					phy-mode = "gmii";
+				};
+			};
 		};
 
 		pcie-controller {
-- 
1.9.1
