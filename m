From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 3/4] arm64: dts: renesas: salvator-common: Add EthernetAVB PHY reset
Date: Thu, 28 Sep 2017 17:53:33 +0200
Message-ID: <1506614014-4398-4-git-send-email-geert+renesas@glider.be>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Describe the GPIO used to reset the Ethernet PHY for EthernetAVB.
This allows the driver to reset the PHY during probe and after system
resume.

This fixes Ethernet operation after resume from s2ram on Salvator-XS,
where the enable pin of the regulator providing PHY power is connected
to PRESETn, and PSCI powers down the SoC during system suspend.

On Salvator-X, the enable pin is always pulled high, but the driver may
still need to reset the PHY if this wasn't done by the bootloader
before.

Inspired by patches in the BSP for the individual Salvator-X/XS boards
by Kazuya Mizuguchi.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
For proper PHY reset operation during system resume, this depends on
"ravb: Add missing PHY reset during system resume".
However, this patch can be applied independently.
---
 arch/arm64/boot/dts/renesas/salvator-common.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/renesas/salvator-common.dtsi b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
index ed4a8dfead3c2e58..db00e7c484f76eac 100644
--- a/arch/arm64/boot/dts/renesas/salvator-common.dtsi
+++ b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
@@ -296,6 +296,7 @@
 	pinctrl-names = "default";
 	renesas,no-ether-link;
 	phy-handle = <&phy0>;
+	reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
 	status = "okay";
 
 	phy0: ethernet-phy@0 {
-- 
2.7.4
