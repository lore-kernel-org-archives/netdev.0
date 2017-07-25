From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 7/8] dt-bindings: net: marvell-pp2: update interrupt-names with TX interrupts
Date: Tue, 25 Jul 2017 17:55:08 +0200
Message-ID: <20170725155509.10574-8-thomas.petazzoni@free-electrons.com>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Cc: Russell King <linux@arm.linux.org.uk>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60490 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdGYPzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:55:41 -0400
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPv2.2 unit has several interrupts used for TX completion
notification. This commit updates the Device Tree binding describing
this HW block to mention such interrupts.

While at it, we update the example to use a recent Device Tree
example, that uses interrupts going through the ICU, and not to the
GIC directly.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-pp2.txt        | 33 +++++++++++++++++-----
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 553aadc..80c4d14 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -44,7 +44,8 @@ Optional properties (port):
 - marvell,system-controller: a phandle to the system controller.
 - interrupt-names: if more than a single interrupt for rx is given, must
                    be the name associated to the interrupts listed. Valid
-                   names are: "rx-shared", "link".
+                   names are: "tx-cpu0", "tx-cpu1", "tx-cpu2", "tx-cpu3",
+		   "rx-shared", "link".
 
 Example for marvell,armada-375-pp2:
 
@@ -84,22 +85,40 @@ cpm_ethernet: ethernet@0 {
 	clock-names = "pp_clk", "gop_clk", "gp_clk";
 
 	eth0: eth0 {
-		interrupts = <GIC_SPI 37 IRQ_TYPE_LEVEL_HIGH>;
-		interrupt-names = "rx-shared";
+		interrupts = <ICU_GRP_NSR 39 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 43 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 47 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 51 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 55 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 129 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+				  "tx-cpu3", "rx-shared", "link";
 		port-id = <0>;
 		gop-port-id = <0>;
 	};
 
 	eth1: eth1 {
-		interrupts = <GIC_SPI 38 IRQ_TYPE_LEVEL_HIGH>;
-		interrupt-names = "rx-shared";
+		interrupts = <ICU_GRP_NSR 40 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 44 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 48 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 52 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 56 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 128 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+				  "tx-cpu3", "rx-shared", "link";
 		port-id = <1>;
 		gop-port-id = <2>;
 	};
 
 	eth2: eth2 {
-		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>;
-		interrupt-names = "rx-shared";
+		interrupts = <ICU_GRP_NSR 41 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 45 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 49 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 53 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 57 IRQ_TYPE_LEVEL_HIGH>,
+			     <ICU_GRP_NSR 127 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "tx-cpu0", "tx-cpu1", "tx-cpu2",
+				  "tx-cpu3", "rx-shared", "link";
 		port-id = <2>;
 		gop-port-id = <3>;
 	};
-- 
2.9.4
