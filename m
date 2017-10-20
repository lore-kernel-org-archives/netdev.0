From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH v3 3/4] arm64: dts: renesas: salvator-common: Add EthernetAVB PHY reset
Date: Fri, 20 Oct 2017 10:14:20 +0200
Message-ID: <1508487261-18524-4-git-send-email-geert+renesas@glider.be>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508487261-18524-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
---
For proper PHY reset operation during system resume, this depends on
"[PATCH v3 2/4] phylib: Add device reset GPIO support".
However, this patch can be applied independently.

v3:
  - Extract from series "[PATCH 0/4] ravb: Add PHY reset support", and
    incorporate in this series,
  - Move reset-gpios from the ethernet to the ethernet-phy node.
---
 arch/arm64/boot/dts/renesas/salvator-common.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/renesas/salvator-common.dtsi b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
index a028cf577ae1d185..78dcb83f59c76333 100644
--- a/arch/arm64/boot/dts/renesas/salvator-common.dtsi
+++ b/arch/arm64/boot/dts/renesas/salvator-common.dtsi
@@ -313,6 +313,7 @@
 		reg = <0>;
 		interrupt-parent = <&gpio2>;
 		interrupts = <11 IRQ_TYPE_LEVEL_LOW>;
+		reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
 	};
 };
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
