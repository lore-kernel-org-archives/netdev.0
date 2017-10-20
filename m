From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 4/4] arm64: dts: renesas: ulcb: Add EthernetAVB PHY reset
Date: Fri, 20 Oct 2017 10:14:21 +0200
Message-ID: <1508487261-18524-5-git-send-email-geert+renesas@glider.be>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Describe the GPIO used to reset the Ethernet PHY for EthernetAVB.
This allows the driver to reset the PHY during probe and after system
resume.

On ULCB, the enable pin of the regulator providing PHY power is always
pulled high, but the driver may still need to reset the PHY if this
wasn't done by the bootloader before.

Inspired by patches in the BSP for the individual Salvator-X/XS boards
by Kazuya Mizuguchi.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Compile-tested only.

v3:
  - Extract from series "[PATCH 0/4] ravb: Add PHY reset support", and
    incorporate in this series,
  - Move reset-gpios from the ethernet to the ethernet-phy node.
---
 arch/arm64/boot/dts/renesas/ulcb.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/renesas/ulcb.dtsi b/arch/arm64/boot/dts/renesas/ulcb.dtsi
index 0d85b315ce711c8f..be91016e0b48f196 100644
--- a/arch/arm64/boot/dts/renesas/ulcb.dtsi
+++ b/arch/arm64/boot/dts/renesas/ulcb.dtsi
@@ -154,6 +154,7 @@
 		reg = <0>;
 		interrupt-parent = <&gpio2>;
 		interrupts = <11 IRQ_TYPE_LEVEL_LOW>;
+		reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
 	};
 };
 
-- 
2.7.4
