From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 05/10] arm: orion5x: Add DT include for mv88f5181
Date: Sat, 16 Jul 2016 15:29:03 +0100
Message-ID: <1468679348-10522-6-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
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

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 .../bindings/arm/marvell/marvell,orion5x.txt       |  1 +
 arch/arm/boot/dts/orion5x-mv88f5181.dtsi           | 35 ++++++++++++++++++++++
 2 files changed, 36 insertions(+)
 create mode 100644 arch/arm/boot/dts/orion5x-mv88f5181.dtsi

diff --git a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
index a888011..ff3c120 100644
--- a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
+++ b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
@@ -9,6 +9,7 @@ compatible: must contain "marvell,orion5x"
 In addition, the above compatible shall be extended with the specific
 SoC. Currently known SoC compatibles are:
 
+"marvell,orion5x-88f5181"
 "marvell,orion5x-88f5182"
 
 And in addition, the compatible shall be extended with the specific
diff --git a/arch/arm/boot/dts/orion5x-mv88f5181.dtsi b/arch/arm/boot/dts/orion5x-mv88f5181.dtsi
new file mode 100644
index 0000000..b51e7ac
--- /dev/null
+++ b/arch/arm/boot/dts/orion5x-mv88f5181.dtsi
@@ -0,0 +1,35 @@
+/*
+ * Copyright (C) 2016 Jamie Lentin <jm@lentin.co.uk>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include "orion5x.dtsi"
+
+/ {
+	compatible = "marvell,orion5x-88f5181", "marvell,orion5x";
+
+	soc {
+		compatible = "marvell,orion5x-88f5181-mbus", "simple-bus";
+
+		internal-regs {
+			pinctrl: pinctrl@10000 {
+				compatible = "marvell,88f5181-pinctrl";
+				reg = <0x10000 0x8>, <0x10050 0x4>;
+			};
+
+			core_clk: core-clocks@10030 {
+				compatible = "marvell,mv88f5181-core-clock";
+				reg = <0x10010 0x4>;
+				#clock-cells = <1>;
+			};
+
+			mbusc: mbus-controller@20000 {
+				compatible = "marvell,mbus-controller";
+				reg = <0x20000 0x100>, <0x1500 0x20>;
+			};
+		};
+	};
+};
-- 
2.8.1
