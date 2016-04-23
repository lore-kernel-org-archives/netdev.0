From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 11/13] Documentation: Bindings: Update DT binding
 for separating dsaf dev support
Date: Sat, 23 Apr 2016 17:05:15 +0800
Message-ID: <1461402317-136499-12-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, salil.mehta@huawei.com, yankejian@huawei.com,
 xieqianqian@huawei.com, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk,
 catalin.marinas@arm.com, lipeng321@huawei.com, will.deacon@arm.com,
 linuxarm@huawei.com, xuwei5@hisilicon.com, robh+dt@kernel.org,
 huangdaode@hisilicon.com, galak@codeaurora.org, liguozhu@huawei.com,
 davem@davemloft.net
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
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

Because debug dsaf port was separated from service dsaf port, this patch
updates the related information of DT binding.

Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>

---
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt | 59 ++++++++++++++++++----
 1 file changed, 49 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
index ecacfa4..5ccd4f0 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
@@ -7,19 +7,47 @@ Required properties:
 - mode: dsa fabric mode string. only support one of dsaf modes like these:
 		"2port-64vf",
 		"6port-16rss",
-		"6port-16vf".
+		"6port-16vf",
+		"single-port".
 - interrupt-parent: the interrupt parent of this device.
 - interrupts: should contain the DSA Fabric and rcb interrupt.
 - reg: specifies base physical address(es) and size of the device registers.
-  The first region is external interface control register base and size.
-  The second region is SerDes base register and size.
+  The first region is external interface control register base and size(optional,
+  only be used when subctrl-syscon is not exists). It is recommended using
+  subctrl-syscon rather than this address.
+  The second region is SerDes base register and size(optional, only be used when
+  serdes-syscon in port node is not exists. It is recommended using
+  serdes-syscon rather than this address.
   The third region is the PPE register base and size.
-  The fourth region is dsa fabric base register and size.
-  The fifth region is cpld base register and size, it is not required if do not use cpld.
-- phy-handle: phy handle of physicl port, 0 if not any phy device. see ethernet.txt [1].
+  The fourth region is dsa fabric base register and size. It is not required for
+  single-port mode.
+- reg-names: may be ppe-base and(or) dsaf-base. It is used to find the
+  corresponding reg's index.
+
+- phy-handle: phy handle of physicl port, 0 if not any phy device. It is optional
+  attribute. If port node is exists, phy-handle in each port node will be used.
+  see ethernet.txt [1].
+- subctrl-syscon: is syscon handle for external interface control register.
+- reset-field-offset: is offset of reset field. Its value depends on the hardware
+  user manual.
 - buf-size: rx buffer size, should be 16-1024.
 - desc-num: number of description in TX and RX queue, should be 512, 1024, 2048 or 4096.
 
+- port: subnodes of dsaf. A dsaf node may contain several port nodes(Depending
+  on mode of dsaf). Port node contain some attributes listed below:
+- port-id: is physical port index in one dsaf.
+- phy-handle: phy handle of physicl port. It is not required if there isn't
+  phy device. see ethernet.txt [1].
+- serdes-syscon: is syscon handle for SerDes register.
+- cpld-syscon: is syscon handle for cpld register. It is not required if there
+  isn't cpld device.
+- cpld-ctrl-reg: is cpld register offset. It is not required if there isn't
+  cpld-syscon.
+- port-rst-offset: is offset of reset field for each port in dsaf. Its value
+  depends on the hardware user manual.
+- port-mode-offset: is offset of port mode field for each port in dsaf. Its
+  value depends on the hardware user manual.
+
 [1] Documentation/devicetree/bindings/net/phy.txt
 
 Example:
@@ -28,11 +56,11 @@ dsaf0: dsa@c7000000 {
 	compatible = "hisilicon,hns-dsaf-v1";
 	mode = "6port-16rss";
 	interrupt-parent = <&mbigen_dsa>;
-	reg = <0x0 0xC0000000 0x0 0x420000
-	       0x0 0xC2000000 0x0 0x300000
-	       0x0 0xc5000000 0x0 0x890000
+	reg = <0x0 0xc5000000 0x0 0x890000
 	       0x0 0xc7000000 0x0 0x60000>;
-	phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
+	reg-names = "ppe-base", "dsaf-base";
+	subctrl-syscon = <&subctrl>;
+	reset-field-offset = 0;
 	interrupts = <131 4>,<132 4>, <133 4>,<134 4>,
 		     <135 4>,<136 4>, <137 4>,<138 4>,
 		     <139 4>,<140 4>, <141 4>,<142 4>,
@@ -43,4 +71,15 @@ dsaf0: dsa@c7000000 {
 	buf-size = <4096>;
 	desc-num = <1024>;
 	dma-coherent;
+
+	prot@0 {
+		port-id = 0;
+		phy-handle = <&phy0>;
+		serdes-syscon = <&serdes>;
+	};
+
+	prot@1 {
+                port-id = 1;
+                serdes-syscon = <&serdes>;
+        };
 };
-- 
1.9.1
