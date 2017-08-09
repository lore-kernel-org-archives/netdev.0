From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v4 12/12] ARM64: dts: rockchip: Enable gmac2phy for rk3328-evb
Date: Wed,  9 Aug 2017 20:14:07 +0800
Message-ID: <1502280847-2634-1-git-send-email-david.wu@rock-chips.com>
References: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the gmac2phy, make the gmac2phy work on
the rk3328-evb board.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm64/boot/dts/rockchip/rk3328-evb.dts | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm64/boot/dts/rockchip/rk3328-evb.dts b/arch/arm64/boot/dts/rockchip/rk3328-evb.dts
index cf27239..b9f36da 100644
--- a/arch/arm64/boot/dts/rockchip/rk3328-evb.dts
+++ b/arch/arm64/boot/dts/rockchip/rk3328-evb.dts
@@ -50,6 +50,23 @@
 	chosen {
 		stdout-path = "serial2:1500000n8";
 	};
+
+	vcc_phy: vcc-phy-regulator {
+		compatible = "regulator-fixed";
+		regulator-name = "vcc_phy";
+		regulator-always-on;
+		regulator-boot-on;
+	};
+};
+
+&gmac2phy {
+	phy-supply = <&vcc_phy>;
+	clock_in_out = "output";
+	assigned-clocks = <&cru SCLK_MAC2PHY_SRC>;
+	assigned-clock-rate = <50000000>;
+	assigned-clocks = <&cru SCLK_MAC2PHY>;
+	assigned-clock-parents = <&cru SCLK_MAC2PHY_SRC>;
+	status = "okay";
 };
 
 &uart2 {
-- 
1.9.1
