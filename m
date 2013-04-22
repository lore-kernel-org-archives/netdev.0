From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 3/3] ARM: dts: AM33XX: add phy fixup for evm and evmsk boards
Date: Mon, 22 Apr 2013 23:50:38 +0530
Message-ID: <1366654838-26479-4-git-send-email-mugunthanvnm@ti.com>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As RGMII tx clock internal delay is not supported in AM335x, the same has
to be enabled in phy. This patch adds support for enabling tx clock internal
delay via phy debug registers

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-evm.dts   |   10 ++++++++++
 arch/arm/boot/dts/am335x-evmsk.dts |   10 ++++++++++
 2 files changed, 20 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index d649644..72805c5 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -244,3 +244,13 @@
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
 };
+
+&davinci_mdio {
+	phy-fixup-registers = <&atheros_txclk_delay_fixup>;
+
+	atheros_txclk_delay_fixup: atheros_txclk_delay_fixup {
+		phy-id = <0x4dd074>;
+		phy-mask = <0xfffffffe>;
+		fixup-registers = <0x1d 0x5 0x1e 0x100>;
+	};
+};
diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index f297b85..f398cb3 100644
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@ -256,3 +256,13 @@
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
 };
+
+&davinci_mdio {
+	phy-fixup-registers = <&atheros_txclk_delay_fixup>;
+
+	atheros_txclk_delay_fixup: atheros_txclk_delay_fixup {
+		phy-id = <0x4dd074>;
+		phy-mask = <0xfffffffe>;
+		fixup-registers = <0x1d 0x5 0x1e 0x100>;
+	};
+};
-- 
1.7.9.5

