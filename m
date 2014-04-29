From: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Subject: [PATCH v3 2/2] Update Micrel KSZ90x1 binding documentation
Date: Tue, 29 Apr 2014 11:33:25 +0200
Message-ID: <1398764005-23855-3-git-send-email-hchaumette@adeneo-embedded.com>
References: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rdunlap@infradead.org, xobs@kosagi.com, davem@davemloft.net,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398764005-23855-1-git-send-email-hchaumette@adeneo-embedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Renames micrel-ksz9021.txt to micrel-ksz90x1.txt and adds documentation for
the KSZ9031 binding from patch 1. Also adds step increment information, and
note about phy fixups. 

Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
---
 .../devicetree/bindings/net/micrel-ksz9021.txt     | 49 -------------
 .../devicetree/bindings/net/micrel-ksz90x1.txt     | 83 ++++++++++++++++++++++
 2 files changed, 83 insertions(+), 49 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/net/micrel-ksz9021.txt
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ksz9021.txt b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
deleted file mode 100644
index 997a63f..0000000
--- a/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
+++ /dev/null
@@ -1,49 +0,0 @@
-Micrel KSZ9021 Gigabit Ethernet PHY
-
-Some boards require special tuning values, particularly when it comes to
-clock delays.  You can specify clock delay values by adding
-micrel-specific properties to an Ethernet OF device node.
-
-All skew control options are specified in picoseconds.  The minimum
-value is 0, and the maximum value is 3000.
-
-Optional properties:
- - rxc-skew-ps : Skew control of RXC pad
- - rxdv-skew-ps : Skew control of RX CTL pad
- - txc-skew-ps : Skew control of TXC pad
- - txen-skew-ps : Skew control of TX_CTL pad
- - rxd0-skew-ps : Skew control of RX data 0 pad
- - rxd1-skew-ps : Skew control of RX data 1 pad
- - rxd2-skew-ps : Skew control of RX data 2 pad
- - rxd3-skew-ps : Skew control of RX data 3 pad
- - txd0-skew-ps : Skew control of TX data 0 pad
- - txd1-skew-ps : Skew control of TX data 1 pad
- - txd2-skew-ps : Skew control of TX data 2 pad
- - txd3-skew-ps : Skew control of TX data 3 pad
-
-Examples:
-
-	/* Attach to an Ethernet device with autodetected PHY */
-	&enet {
-		rxc-skew-ps = <3000>;
-		rxdv-skew-ps = <0>;
-		txc-skew-ps = <3000>;
-		txen-skew-ps = <0>;
-		status = "okay";
-	};
-
-	/* Attach to an explicitly-specified PHY */
-	mdio {
-		phy0: ethernet-phy@0 {
-			rxc-skew-ps = <3000>;
-			rxdv-skew-ps = <0>;
-			txc-skew-ps = <3000>;
-			txen-skew-ps = <0>;
-			reg = <0>;
-		};
-	};
-	ethernet@70000 {
-		status = "okay";
-		phy = <&phy0>;
-		phy-mode = "rgmii-id";
-	};
diff --git a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
new file mode 100644
index 0000000..692076f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
@@ -0,0 +1,83 @@
+Micrel KSZ9021/KSZ9031 Gigabit Ethernet PHY
+
+Some boards require special tuning values, particularly when it comes to
+clock delays. You can specify clock delay values by adding
+micrel-specific properties to an Ethernet OF device node.
+
+Note that these settings are applied after any phy-specific fixup from
+phy_fixup_list (see phy_init_hw() from drivers/net/phy/phy_device.c),
+and therefore may overwrite them.
+
+KSZ9021:
+
+  All skew control options are specified in picoseconds. The minimum
+  value is 0, the maximum value is 3000, and it is incremented by 200ps
+  steps.
+
+  Optional properties:
+
+    - rxc-skew-ps : Skew control of RXC pad
+    - rxdv-skew-ps : Skew control of RX CTL pad
+    - txc-skew-ps : Skew control of TXC pad
+    - txen-skew-ps : Skew control of TX CTL pad
+    - rxd0-skew-ps : Skew control of RX data 0 pad
+    - rxd1-skew-ps : Skew control of RX data 1 pad
+    - rxd2-skew-ps : Skew control of RX data 2 pad
+    - rxd3-skew-ps : Skew control of RX data 3 pad
+    - txd0-skew-ps : Skew control of TX data 0 pad
+    - txd1-skew-ps : Skew control of TX data 1 pad
+    - txd2-skew-ps : Skew control of TX data 2 pad
+    - txd3-skew-ps : Skew control of TX data 3 pad
+
+KSZ9031:
+
+  All skew control options are specified in picoseconds. The minimum
+  value is 0, and the maximum is property-dependent. The increment
+  step is 60ps.
+
+  Optional properties:
+
+    Maximum value of 1860:
+
+      - rxc-skew-ps : Skew control of RX clock pad
+      - txc-skew-ps : Skew control of TX clock pad
+
+    Maximum value of 900:
+
+      - rxdv-skew-ps : Skew control of RX CTL pad
+      - txen-skew-ps : Skew control of TX CTL pad
+      - rxd0-skew-ps : Skew control of RX data 0 pad
+      - rxd1-skew-ps : Skew control of RX data 1 pad
+      - rxd2-skew-ps : Skew control of RX data 2 pad
+      - rxd3-skew-ps : Skew control of RX data 3 pad
+      - txd0-skew-ps : Skew control of TX data 0 pad
+      - txd1-skew-ps : Skew control of TX data 1 pad
+      - txd2-skew-ps : Skew control of TX data 2 pad
+      - txd3-skew-ps : Skew control of TX data 3 pad
+
+Examples:
+
+	/* Attach to an Ethernet device with autodetected PHY */
+	&enet {
+		rxc-skew-ps = <3000>;
+		rxdv-skew-ps = <0>;
+		txc-skew-ps = <3000>;
+		txen-skew-ps = <0>;
+		status = "okay";
+	};
+
+	/* Attach to an explicitly-specified PHY */
+	mdio {
+		phy0: ethernet-phy@0 {
+			rxc-skew-ps = <3000>;
+			rxdv-skew-ps = <0>;
+			txc-skew-ps = <3000>;
+			txen-skew-ps = <0>;
+			reg = <0>;
+		};
+	};
+	ethernet@70000 {
+		status = "okay";
+		phy = <&phy0>;
+		phy-mode = "rgmii-id";
+	};
-- 
1.9.2
