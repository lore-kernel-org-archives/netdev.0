From: Icenowy Zheng <icenowy@aosc.io>
Subject: [PATCH v3 2/2] ARM: sun8i: h2+: specify wifi interrupts for Orange Pi Zero
Date: Wed,  4 Oct 2017 00:59:44 +0800
Message-ID: <20171003165944.13056-3-icenowy@aosc.io>
References: <20171003165944.13056-1-icenowy@aosc.io>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-sunxi@googlegroups.com,
        Sergey Matyukevich <geomatsi@gmail.com>,
        Icenowy Zheng <icenowy@aosc.io>
To: Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003165944.13056-1-icenowy@aosc.io>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Matyukevich <geomatsi@gmail.com>

The Orange Pi Zero board has Allwinner XR819 SDIO wifi chip. The board
dts file provides a node enabling mmc1 controller, and a out-of-band
interrupt line of the chip is also connected, although the chip also
supports in-band interrupt.

The current out-of-tree driver is hardcoded to use out-of-band interrupt
as default, and it needs to be modified to use the in-band interrupt.

This commit adds the out-of-band interrupt line into the device tree.

Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>
[Icenowy: Changed vendor prefix to allwinner and modify commit message]
Signed-off-by: Icenowy Zheng <icenowy@aosc.io>
---
Changes in v3 by Icenowy:
- Change the compatible string vendor prefix to "allwinner".
- Modify the commit message.
Changes in v2 by Sergey:
- Adds the compatible string.

 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
index b1502df7b509..6595617204b3 100644
--- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
+++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
@@ -127,6 +127,9 @@
 	 */
 	xr819: sdio_wifi@1 {
 		reg = <1>;
+		compatible = "allwinner,xr819";
+		interrupt-parent = <&pio>;
+		interrupts = <6 10 IRQ_TYPE_EDGE_RISING>;
 	};
 };
 
-- 
2.13.5
