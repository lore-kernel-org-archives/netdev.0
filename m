From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] ARM: dts: am57xx-beagle-x15: implement errata "Ethernet RGMII2 Limited to 10/100 Mbps"
Date: Thu, 12 Jan 2017 11:14:29 -0600
Message-ID: <20170112171429.8106-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>, Sekhar Nori <nsekhar@ti.com>,
        <netdev@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Tony Lindgren <tony@atomide.com>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:29800 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdALRO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 12:14:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to errata i880 description the speed of Ethernet port 1 on AM572x
SoCs rev 1.1 shuld be limited to 10/100Mbps, because RGMII2 Switching
Characteristics are not compatible with 1000 Mbps operation [1].
The issue is fixed with Rev 2.0 silicon.

Hence, rework Beagle-X15 and Begale-X15-revb1 to use phy-handle instead of
phy_id and apply corresponding limitation to the Ethernet Phy 1.

[1] http://www.ti.com/lit/er/sprz429j/sprz429j.pdf

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 arch/arm/boot/dts/am57xx-beagle-x15-common.dtsi | 14 ++++++++++++--
 arch/arm/boot/dts/am57xx-beagle-x15-revb1.dts   |  5 +++++
 arch/arm/boot/dts/am57xx-beagle-x15.dts         |  5 +++++
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/am57xx-beagle-x15-common.dtsi b/arch/arm/boot/dts/am57xx-beagle-x15-common.dtsi
index 78bee26..0429fa0 100644
--- a/arch/arm/boot/dts/am57xx-beagle-x15-common.dtsi
+++ b/arch/arm/boot/dts/am57xx-beagle-x15-common.dtsi
@@ -421,19 +421,29 @@
 			      <&dra7_pmx_core 0x3f8>;
 };
 
+&davinci_mdio {
+	phy0: ethernet-phy@1 {
+		reg = <1>;
+	};
+
+	phy1: ethernet-phy@2 {
+		reg = <2>;
+	};
+};
+
 &mac {
 	status = "okay";
 	dual_emac;
 };
 
 &cpsw_emac0 {
-	phy_id = <&davinci_mdio>, <1>;
+	phy-handle = <&phy0>;
 	phy-mode = "rgmii";
 	dual_emac_res_vlan = <1>;
 };
 
 &cpsw_emac1 {
-	phy_id = <&davinci_mdio>, <2>;
+	phy-handle = <&phy1>;
 	phy-mode = "rgmii";
 	dual_emac_res_vlan = <2>;
 };
diff --git a/arch/arm/boot/dts/am57xx-beagle-x15-revb1.dts b/arch/arm/boot/dts/am57xx-beagle-x15-revb1.dts
index ca85570..39a92af 100644
--- a/arch/arm/boot/dts/am57xx-beagle-x15-revb1.dts
+++ b/arch/arm/boot/dts/am57xx-beagle-x15-revb1.dts
@@ -22,3 +22,8 @@
 	vmmc-supply = <&vdd_3v3>;
 	vmmc-aux-supply = <&ldo1_reg>;
 };
+
+/* errata i880 "Ethernet RGMII2 Limited to 10/100 Mbps" */
+&phy1 {
+	max-speed = <100>;
+};
diff --git a/arch/arm/boot/dts/am57xx-beagle-x15.dts b/arch/arm/boot/dts/am57xx-beagle-x15.dts
index 8c66f2e..19a60a1 100644
--- a/arch/arm/boot/dts/am57xx-beagle-x15.dts
+++ b/arch/arm/boot/dts/am57xx-beagle-x15.dts
@@ -22,3 +22,8 @@
 &mmc1 {
 	vmmc-supply = <&ldo1_reg>;
 };
+
+/* errata i880 "Ethernet RGMII2 Limited to 10/100 Mbps" */
+&phy1 {
+	max-speed = <100>;
+};
-- 
2.10.1.dirty
