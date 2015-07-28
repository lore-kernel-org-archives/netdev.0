From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net-next 1/4] dwc_eth_qos: Add Synopsys DWC Ethernet QoS bindings
Date: Tue, 28 Jul 2015 12:01:47 +0200
Message-ID: <1438077710-19175-2-git-send-email-larper@axis.com>
References: <1438077710-19175-1-git-send-email-larper@axis.com>
Cc: andire@axis.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438077710-19175-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree binding documentation for the Synopsys DWC Ethernet
QoS driver supporting revision 4.10a of the hardware IP.

Signed-off-by: Lars Persson <larper@axis.com>
---
 .../bindings/net/snps,dwc-qos-ethernet.txt         | 75 ++++++++++++++++++++++
 1 file changed, 75 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt

diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
new file mode 100644
index 0000000..51f8d2e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
@@ -0,0 +1,75 @@
+* Synopsys DWC Ethernet QoS IP version 4.10 driver (GMAC)
+
+
+Required properties:
+- compatible: Should be "snps,dwc-qos-ethernet-4.10"
+- reg: Address and length of the register set for the device
+- clocks: Phandles to the reference clock and the bus clock
+- clock-names: Should be "phy_ref_clk" for the reference clock and "apb_pclk"
+  for the bus clock.
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- interrupts: Should contain the core's combined interrupt signal
+- phy-mode: See ethernet.txt file in the same directory
+
+Optional properties:
+- dma-coherent: Present if dma operations are coherent
+- mac-address: See ethernet.txt in the same directory
+- local-mac-address: See ethernet.txt in the same directory
+- snps,en-lpi: If present it enables use of the AXI low-power interface
+- snps,write-requests: Number of write requests that the AXI port can issue.
+  It depends on the SoC configuration.
+- snps,read-requests: Number of read requests that the AXI port can issue.
+  It depends on the SoC configuration.
+- snps,burst-map: Bitmap of allowed AXI burst lengts, with the LSB
+  representing 4, then 8 etc.
+- snps,txpbl: DMA Programmable burst length for the TX DMA
+- snps,rxpbl: DMA Programmable burst length for the RX DMA
+- snps,en-tx-lpi-clockgating: Enable gating of the MAC TX clock during
+  TX low-power mode.
+- phy-handle: See ethernet.txt file in the same directory
+- mdio device tree subnode: When the GMAC has a phy connected to its local
+    mdio, there must be device tree subnode with the following
+    required properties:
+    - compatible: Must be "snps,dwc-qos-ethernet-mdio".
+    - #address-cells: Must be <1>.
+    - #size-cells: Must be <0>.
+
+    For each phy on the mdio bus, there must be a node with the following
+    fields:
+
+    - reg: phy id used to communicate to phy.
+    - device_type: Must be "ethernet-phy".
+    - fixed-mode device tree subnode: see fixed-link.txt in the same directory
+
+Examples:
+ethernet2@40010000 {
+	clock-names = "phy_ref_clk", "apb_pclk";
+	clocks = <&clkc 17>, <&clkc 15>;
+	compatible = "snps,dwc-qos-ethernet-4.10";
+	interrupt-parent = <&intc>;
+	interrupts = <0x0 0x1e 0x4>;
+	reg = <0x40010000 0x4000>;
+	phy-handle = <&phy2>;
+	phy-mode = "gmii";
+
+	snps,en-tx-lpi-clockgating;
+	snps,en-lpi;
+	snps,write-requests = <2>;
+	snps,read-requests = <16>;
+	snps,burst-map = <0x7>;
+	snps,txpbl = <8>;
+	snps,rxpbl = <2>;
+
+	dma-coherent;
+
+	mdio {
+		#address-cells = <0x1>;
+		#size-cells = <0x0>;
+		phy2: phy@1 {
+			compatible = "ethernet-phy-ieee802.3-c22";
+			device_type = "ethernet-phy";
+			reg = <0x1>;
+		};
+	};
+};
-- 
2.1.4
