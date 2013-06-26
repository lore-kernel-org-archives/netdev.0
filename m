From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH v2] arch/arc: angel4.dts - add description for "arc_emac"
Date: Wed, 26 Jun 2013 14:02:18 +0400
Message-ID: <1372240938-28733-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Joe Perches" <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us02smtp1.synopsys.com ([198.182.60.75]:38871 "EHLO
	vaxjo.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab3FZKCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 06:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch we introduce DT "arc_emac" description for ARCangel4.
Description is based on info/example in
"Documentation/devicetree/bindings/net/arc_emac.txt".

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Joe Perches <joe@perches.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Florian Fainelli <florian@openwrt.org>

---

This re-spin also removes obsolete mentions of IRQ number and
base-address of arc_emac from "plat_arcfpga".
---
 arch/arc/boot/dts/angel4.dts                |   16 ++++++++++++++++
 arch/arc/plat-arcfpga/include/plat/irq.h    |    2 --
 arch/arc/plat-arcfpga/include/plat/memmap.h |    2 --
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/arch/arc/boot/dts/angel4.dts b/arch/arc/boot/dts/angel4.dts
index bae4f93..4fb2d6f 100644
--- a/arch/arc/boot/dts/angel4.dts
+++ b/arch/arc/boot/dts/angel4.dts
@@ -51,5 +51,21 @@
 			current-speed = <115200>;
 			status = "okay";
 		};
+
+		ethernet@c0fc2000 {
+			compatible = "snps,arc-emac";
+			reg = <0xc0fc2000 0x3c>;
+			interrupts = <6>;
+			mac-address = [ 00 11 22 33 44 55 ];
+			clock-frequency = <80000000>;
+			max-speed = <100>;
+			phy = <&phy0>;
+
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy0: ethernet-phy@0 {
+				reg = <1>;
+			};
+		};
 	};
 };
diff --git a/arch/arc/plat-arcfpga/include/plat/irq.h b/arch/arc/plat-arcfpga/include/plat/irq.h
index 41e3356..6adbc53 100644
--- a/arch/arc/plat-arcfpga/include/plat/irq.h
+++ b/arch/arc/plat-arcfpga/include/plat/irq.h
@@ -16,8 +16,6 @@
 #define UART1_IRQ	10
 #define UART2_IRQ	11
 
-#define VMAC_IRQ	6
-
 #define IDE_IRQ		13
 #define PCI_IRQ		14
 #define PS2_IRQ		15
diff --git a/arch/arc/plat-arcfpga/include/plat/memmap.h b/arch/arc/plat-arcfpga/include/plat/memmap.h
index 1663f33..5c78e61 100644
--- a/arch/arc/plat-arcfpga/include/plat/memmap.h
+++ b/arch/arc/plat-arcfpga/include/plat/memmap.h
@@ -15,8 +15,6 @@
 #define UART0_BASE              0xC0FC1000
 #define UART1_BASE              0xC0FC1100
 
-#define VMAC_REG_BASEADDR       0xC0FC2000
-
 #define IDE_CONTROLLER_BASE     0xC0FC9000
 
 #define AHB_PCI_HOST_BRG_BASE   0xC0FD0000
-- 
1.7.10.4
