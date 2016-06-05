From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: [PATCH 1/2] NET: PHY: Add PHY LED control binding.
Date: Sun,  5 Jun 2016 23:45:49 +0200
Message-ID: <1465163150-21429-2-git-send-email-hauke@hauke-m.de>
References: <1465163150-21429-1-git-send-email-hauke@hauke-m.de>
Cc: alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, openwrt-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org,
	hauke.mehrtens-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, daniel.schwierzeck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	eckert.florian-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	thomas.langer-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465163150-21429-1-git-send-email-hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This binding makes it possible to control the LEDs of an Ethernet PHY.
These settings allow it to abstract the hardware configuration which
tells the hardware when to switch the LED constant on or blink for
example. This will be used by the Intel XWAY PHY driver.  I also
checked datasheets for some other Ethernet PHYs and it should be
possible to also control their LED behavior with these settings, but
they all did not allow a so fine control over the LED behavior.

Signed-off-by: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
---
 Documentation/devicetree/bindings/phy/phy-leds.txt | 52 ++++++++++++++++++++++
 include/dt-bindings/phy/phy-leds.h                 | 27 +++++++++++
 2 files changed, 79 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/phy-leds.txt
 create mode 100644 include/dt-bindings/phy/phy-leds.h

diff --git a/Documentation/devicetree/bindings/phy/phy-leds.txt b/Documentation/devicetree/bindings/phy/phy-leds.txt
new file mode 100644
index 0000000..1a35e3d
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/phy-leds.txt
@@ -0,0 +1,52 @@
+LED configuration for Ethernet phys
+
+All these properties are optional, not all properties are supported by
+all PHYs. When more then one property name is define for one LED the
+order they get applied is device depended.
+Property names:
+	led-const-on: conditions the LED should be constant on
+	led-pulse: condition the LED should be pulsed on
+	led-blink-slow: condition the LED should slowly blink
+	led-blink-fast: condition the LED should fast blink
+
+These property values define the states a LED is triggered by the
+hardware. Not all PHYs support all states. It is possible to connect
+these property values with OR to trigger the LED in multiple stats like
+10MBit/s and 100MBit/s. The possible combinations are device specific.
+property values:
+	PHY_LED_OFF:		LED is off
+	PHY_LED_LINK10:		link is 10MBit/s
+	PHY_LED_LINK100:	link is 100MBit/s
+	PHY_LED_LINK1000:	link is 1000MBit/s
+	PHY_LED_PDOWN:		link is powered down
+	PHY_LED_EEE:		link is in EEE mode
+	PHY_LED_ANEG:		auto negotiation is running
+	PHY_LED_ABIST:		analog self testing is running
+	PHY_LED_CDIAG:		cable diagnostics is running
+	PHY_LED_COPPER:		copper interface detected
+	PHY_LED_FIBER:		fiber interface detected
+	PHY_LED_TXACT:		Transmit activity
+	PHY_LED_RXACT:		Receive activity
+	PHY_LED_COL:		Collision
+
+Example:
+
+#include <dt-bindings/phy/phy-leds.h>
+phy@0 {
+	compatible = "ethernet-phy-ieee802.3-c22";
+	reg = <0x0>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+	led@0 {
+		compatible = "phy,led";
+		reg = <0>;
+		led-const-on = <(PHY_LED_LINK10 | PHY_LED_LINK100 | PHY_LED_LINK1000)>;
+		led-pulse = <(PHY_LED_TXACT | PHY_LED_RXACT)>;
+	};
+	led@2 {
+		compatible = "phy,led";
+		reg = <2>;
+		led-blink-slow = <PHY_LED_EEE>;
+		led-blink-fast = <PHY_LED_PDOWN>;
+	};
+};
diff --git a/include/dt-bindings/phy/phy-leds.h b/include/dt-bindings/phy/phy-leds.h
new file mode 100644
index 0000000..801fdaf
--- /dev/null
+++ b/include/dt-bindings/phy/phy-leds.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2016 Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+#ifndef _DT_BINDINGS_PHY_LEDS
+#define _DT_BINDINGS_PHY_LEDS
+
+#define PHY_LED_OFF		(1 << 0)  /* is off */
+#define PHY_LED_LINK10		(1 << 1)  /* link is 10MBit/s */
+#define PHY_LED_LINK100		(1 << 2)  /* link is 100MBit/s */
+#define PHY_LED_LINK1000	(1 << 3)  /* link is 1000MBit/s */
+#define PHY_LED_PDOWN		(1 << 4)  /* link is powered down */
+#define PHY_LED_EEE		(1 << 5)  /* link is in EEE mode */
+#define PHY_LED_ANEG		(1 << 6)  /* auto negotiation is running */
+#define PHY_LED_ABIST		(1 << 7)  /* analog self testing is running */
+#define PHY_LED_CDIAG		(1 << 8)  /* cable diagnostics is running */
+#define PHY_LED_COPPER		(1 << 9)  /* copper interface detected */
+#define PHY_LED_FIBER		(1 << 10) /* fiber interface detected */
+#define PHY_LED_TXACT		(1 << 11) /* Transmit activity */
+#define PHY_LED_RXACT		(1 << 12) /* Receive activity */
+#define PHY_LED_COL		(1 << 13) /* Collision */
+
+#endif /* _DT_BINDINGS_PHY_LEDS */
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
