From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 2/2] net: hns: enet specisies a reference to dsaf
 (config and documents)
Date: Sat, 5 Dec 2015 15:59:16 +0800
Message-ID: <1449302356-54658-3-git-send-email-yankejian@huawei.com>
References: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linuxarm@huawei.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <arnd@arndb.de>, <fengguang.wu@intel.com>,
 <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
 <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>,
 <salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
 <liguozhu@huawei.com>, <lisheng011@huawei.com>,
 <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

when enet specisies a reference to dsaf, the correlative config and
documents needs to update. this patch updates the correlative dtsi file
and bindings documents .

Signed-off-by: yankejian <yankejian@huawei.com>
---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
 .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index 80411b2..ecacfa4 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -4,8 +4,6 @@ Required properties:
 - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
   "hisilicon,hns-dsaf-v1" is for hip05.
   "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
-- dsa-name: dsa fabric name who provide this interface.
-  should be "dsafX", X is the dsaf id.
 - mode: dsa fabric mode string. only support one of dsaf modes like these:
 		"2port-64vf",
 		"6port-16rss",
@@ -26,9 +24,8 @@ Required properties:
 
 Example:
 
-dsa: dsa@c7000000 {
+dsaf0: dsa@c7000000 {
 	compatible = "hisilicon,hns-dsaf-v1";
-	dsa_name = "dsaf0";
 	mode = "6port-16rss";
 	interrupt-parent = <&mbigen_dsa>;
 	reg = <0x0 0xC0000000 0x0 0x420000
diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
index 41d19be..e6a9d1c 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
@@ -4,8 +4,9 @@ Required properties:
 - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
   "hisilicon,hns-nic-v1" is for hip05.
   "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
-- ae-name: accelerator name who provides this interface,
-  is simply a name referring to the name of name in the accelerator node.
+- ae-handle: accelerator engine handle for hns,
+  specifies a reference to the associating hardware driver node.
+  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
 - port-id: is the index of port provided by DSAF (the accelerator). DSAF can
   connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
   are called debug ports.
@@ -41,7 +42,7 @@ Example:
 
 	ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <0>;
 		local-mac-address = [a2 14 e4 4b 56 76];
 	};
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 606dd5a..89c883e 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -23,9 +23,8 @@ soc0: soc@000000000 {
 		};
 	};
 
-	dsa: dsa@c7000000 {
+	dsaf0: dsa@c7000000 {
 		compatible = "hisilicon,hns-dsaf-v1";
-		dsa_name = "dsaf0";
 		mode = "6port-16rss";
 		interrupt-parent = <&mbigen_dsa>;
 
@@ -127,7 +126,7 @@ soc0: soc@000000000 {
 
 	eth0: ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <0>;
 		local-mac-address = [00 00 00 01 00 58];
 		status = "disabled";
@@ -135,14 +134,14 @@ soc0: soc@000000000 {
 	};
 	eth1: ethernet@1{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <1>;
 		status = "disabled";
 		dma-coherent;
 	};
 	eth2: ethernet@2{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <2>;
 		local-mac-address = [00 00 00 01 00 5a];
 		status = "disabled";
@@ -150,7 +149,7 @@ soc0: soc@000000000 {
 	};
 	eth3: ethernet@3{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <3>;
 		local-mac-address = [00 00 00 01 00 5b];
 		status = "disabled";
@@ -158,7 +157,7 @@ soc0: soc@000000000 {
 	};
 	eth4: ethernet@4{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <4>;
 		local-mac-address = [00 00 00 01 00 5c];
 		status = "disabled";
@@ -166,7 +165,7 @@ soc0: soc@000000000 {
 	};
 	eth5: ethernet@5{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <5>;
 		local-mac-address = [00 00 00 01 00 5d];
 		status = "disabled";
@@ -174,7 +173,7 @@ soc0: soc@000000000 {
 	};
 	eth6: ethernet@6{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <6>;
 		local-mac-address = [00 00 00 01 00 5e];
 		status = "disabled";
@@ -182,7 +181,7 @@ soc0: soc@000000000 {
 	};
 	eth7: ethernet@7{
 		compatible = "hisilicon,hns-nic-v1";
-		ae-name = "dsaf0";
+		ae-handle = <&dsaf0>;
 		port-id = <7>;
 		local-mac-address = [00 00 00 01 00 5f];
 		status = "disabled";
-- 
1.9.1
