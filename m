From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 13/13] dts: hisi: update hns dst for separating dsaf dev support
Date: Sat, 23 Apr 2016 17:05:17 +0800
Message-ID: <1461402317-136499-14-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <will.deacon@arm.com>,
	<catalin.marinas@arm.com>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <xuwei5@hisilicon.com>,
	<linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:47087 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcDWIsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 04:48:45 -0400
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because debug dsaf port was separated from service dsaf port, this patch
updates the related configurations of hns dts, changes it to match with
the new binding files. This also removes enet nodes which don't exist in
d02 board.

Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi | 72 ++++++++++++----------------
 1 file changed, 30 insertions(+), 42 deletions(-)

diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 933cba3..058cb78 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -28,13 +28,13 @@ soc0: soc@000000000 {
 		mode = "6port-16rss";
 		interrupt-parent = <&mbigen_dsa>;
 
-		reg = <0x0 0xC0000000 0x0 0x420000
-		       0x0 0xC2000000 0x0 0x300000
-		       0x0 0xc5000000 0x0 0x890000
+		reg = <0x0 0xc5000000 0x0 0x890000
 		       0x0 0xc7000000 0x0 0x60000
 		       >;
 
-		phy-handle = <0 0 0 0 &soc0_phy0 &soc0_phy1 0 0>;
+		reg-names = "ppe-base","dsaf-base";
+		subctrl-syscon = <&dsaf_subctrl>;
+		reset-field-offset = <0>;
 		interrupts = <
 			/* [14] ge fifo err 8 / xge 6**/
 			149 0x4 150 0x4 151 0x4 152 0x4
@@ -122,12 +122,31 @@ soc0: soc@000000000 {
 		buf-size = <4096>;
 		desc-num = <1024>;
 		dma-coherent;
+
+		port@0 {
+			port-id = <0>;
+			serdes-syscon = <&serdes_ctrl0>;
+		};
+		port@1 {
+			port-id = <1>;
+			serdes-syscon = <&serdes_ctrl0>;
+		};
+		port@4 {
+			port-id = <4>;
+			phy-handle = <&soc0_phy0>;
+			serdes-syscon = <&serdes_ctrl1>;
+		};
+		port@5 {
+			port-id = <5>;
+			phy-handle = <&soc0_phy1>;
+			serdes-syscon = <&serdes_ctrl1>;
+		};
 	};
 
 	eth0: ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <0>;
+		port-idx-in-ae = <0>;
 		local-mac-address = [00 00 00 01 00 58];
 		status = "disabled";
 		dma-coherent;
@@ -135,56 +154,25 @@ soc0: soc@000000000 {
 	eth1: ethernet@1{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <1>;
+		port-idx-in-ae = <1>;
+		local-mac-address = [00 00 00 01 00 59];
 		status = "disabled";
 		dma-coherent;
 	};
-	eth2: ethernet@2{
+	eth2: ethernet@4{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <2>;
+		port-idx-in-ae = <4>;
 		local-mac-address = [00 00 00 01 00 5a];
 		status = "disabled";
 		dma-coherent;
 	};
-	eth3: ethernet@3{
+	eth3: ethernet@5{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <3>;
+		port-idx-in-ae = <5>;
 		local-mac-address = [00 00 00 01 00 5b];
 		status = "disabled";
 		dma-coherent;
 	};
-	eth4: ethernet@4{
-		compatible = "hisilicon,hns-nic-v1";
-		ae-handle = <&dsaf0>;
-		port-id = <4>;
-		local-mac-address = [00 00 00 01 00 5c];
-		status = "disabled";
-		dma-coherent;
-	};
-	eth5: ethernet@5{
-		compatible = "hisilicon,hns-nic-v1";
-		ae-handle = <&dsaf0>;
-		port-id = <5>;
-		local-mac-address = [00 00 00 01 00 5d];
-		status = "disabled";
-		dma-coherent;
-	};
-	eth6: ethernet@6{
-		compatible = "hisilicon,hns-nic-v1";
-		ae-handle = <&dsaf0>;
-		port-id = <6>;
-		local-mac-address = [00 00 00 01 00 5e];
-		status = "disabled";
-		dma-coherent;
-	};
-	eth7: ethernet@7{
-		compatible = "hisilicon,hns-nic-v1";
-		ae-handle = <&dsaf0>;
-		port-id = <7>;
-		local-mac-address = [00 00 00 01 00 5f];
-		status = "disabled";
-		dma-coherent;
-	};
 };
-- 
1.9.1
