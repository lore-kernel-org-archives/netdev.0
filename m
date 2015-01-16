From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next v8 1/4] Documentation: dt: net: Add binding doc for Keystone NetCP ethernet driver
Date: Thu, 15 Jan 2015 19:12:49 -0500
Message-ID: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <santosh.shilimkar@kernel.org>
To: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The network coprocessor (NetCP) is a hardware accelerator that processes
Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
switch sub-module to send and receive packets. NetCP also includes a packet
accelerator (PA) module to perform packet classification operations such as
header matching, and packet modification operations such as checksum
generation. NetCP can also optionally include a Security Accelerator(SA)
capable of performing IPSec operations on ingress/egress packets.

Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
1Gb/s rates per Ethernet port.

NetCP Subsystem device tree layout looks something like below:

-----------------------------
  NetCP subsystem(10G or 1G)
-----------------------------
	|
	|-> NetCP Devices ->	|
	|			|-> GBE/XGBE Switch
	|			|
	|			|-> Packet Accelerator
	|			|
	|			|-> Security Accelerator
	|
	|
	|
	|-> NetCP Interfaces ->	|
				|-> Ethernet Port 0
				|
				|-> Ethernet Port 1
				|
				|-> Ethernet Port 2
				|
				|-> Ethernet Port 3

Common driver supports GBE as well XGBE network processors.

Cc: Rob Herring <robh+dt@kernel.org>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Pawel Moll <pawel.moll@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
Cc: Kumar Gala <galak@codeaurora.org>
Cc: David Miller <davem@davemloft.net>
Cc: Santosh Shilimkar <santosh.shilimkar@kernel.org>

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |  197 ++++++++++++++++++++
 1 file changed, 197 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/keystone-netcp.txt

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
new file mode 100644
index 0000000..f9c0771
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -0,0 +1,197 @@
+This document describes the device tree bindings associated with the
+keystone network coprocessor(NetCP) driver support.
+
+The network coprocessor (NetCP) is a hardware accelerator that processes
+Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsytem with a ethernet
+switch sub-module to send and receive packets. NetCP also includes a packet
+accelerator (PA) module to perform packet classification operations such as
+header matching, and packet modification operations such as checksum
+generation. NetCP can also optionally include a Security Accelerator (SA)
+capable of performing IPSec operations on ingress/egress packets.
+
+Keystone II SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
+includes a 3-port Ethernet switch sub-module capable of 10Gb/s and 1Gb/s rates
+per Ethernet port.
+
+Keystone NetCP driver has a plug-in module architecture where each of the NetCP
+sub-modules exist as a loadable kernel module which plug in to the netcp core.
+These sub-modules are represented as "netcp-devices" in the dts bindings. It is
+mandatory to have the ethernet switch sub-module for the ethernet interface to
+be operational. Any other sub-module like the PA is optional.
+
+NetCP Ethernet SubSystem Layout:
+
+-----------------------------
+  NetCP subsystem(10G or 1G)
+-----------------------------
+	|
+	|-> NetCP Devices ->	|
+	|			|-> GBE/XGBE Switch
+	|			|
+	|			|-> Packet Accelerator
+	|			|
+	|			|-> Security Accelerator
+	|
+	|
+	|
+	|-> NetCP Interfaces ->	|
+				|-> Ethernet Port 0
+				|
+				|-> Ethernet Port 1
+				|
+				|-> Ethernet Port 2
+				|
+				|-> Ethernet Port 3
+
+
+NetCP subsystem properties:
+Required properties:
+- compatible:	Should be "ti,netcp-1.0"
+- clocks:	phandle to the reference clocks for the subsystem.
+- dma-id:	Navigator packet dma instance id.
+
+Optional properties:
+- reg:		register location and the size for the following register
+		regions in the specified order.
+		- Efuse MAC address register
+- dma-coherent:	Present if dma operations are coherent
+- big-endian:	Keystone devices can be operated in a mode where the DSP is in
+		the big endian mode. In such cases enable this option. This
+		option should also be enabled if the ARM is operated in
+		big endian mode with the DSP in little endian.
+
+NetCP device properties: Device specification for NetCP sub-modules.
+1Gb/10Gb (gbe/xgbe) ethernet switch sub-module specifications.
+Required properties:
+- label:	Must be "netcp-gbe" for 1Gb & "netcp-xgbe" for 10Gb.
+- reg:		register location and the size for the following register
+		regions in the specified order.
+		- subsystem registers
+		- serdes registers
+- tx-channel:	the navigator packet dma channel name for tx.
+- tx-queue:	the navigator queue number associated with the tx dma channel.
+- interfaces:	specification for each of the switch port to be registered as a
+		network interface in the stack.
+-- slave-port:	Switch port number, 0 based numbering.
+-- link-interface:	type of link interface, supported options are
+			- mac<->mac auto negotiate mode: 0
+			- mac<->phy mode: 1
+			- mac<->mac forced mode: 2
+			- mac<->fiber mode: 3
+			- mac<->phy mode with no mdio: 4
+			- 10Gb mac<->phy mode : 10
+			- 10Gb mac<->mac forced mode : 11
+----phy-handle:	phandle to PHY device
+
+Optional properties:
+- enable-ale:	NetCP driver keeps the address learning feature in the ethernet
+		switch module disabled. This attribute is to enable the address
+		learning.
+- secondary-slave-ports:	specification for each of the switch port not be
+				registered as a network interface. NetCP driver
+				will only initialize these ports and attach PHY
+				driver to them if needed.
+
+NetCP interface properties: Interface specification for NetCP sub-modules.
+Required properties:
+- rx-channel:	the navigator packet dma channel name for rx.
+- rx-queue:	the navigator queue number associated with rx dma channel.
+- rx-pool:	specifies the number of descriptors to be used & the region-id
+		for creating the rx descriptor pool.
+- tx-pool:	specifies the number of descriptors to be used & the region-id
+		for creating the tx descriptor pool.
+- rx-queue-depth:	number of descriptors in each of the free descriptor
+			queue (FDQ) for the pktdma Rx flow. There can be at
+			present a maximum of 4 queues per Rx flow.
+- rx-buffer-size:	the buffer size for each of the Rx flow FDQ.
+- tx-completion-queue:	the navigator queue number where the descriptors are
+			recycled after Tx DMA completion.
+
+Optional properties:
+- efuse-mac:	If this is 1, then the MAC address for the interface is
+		obtained from the device efuse mac address register
+- local-mac-address:	the driver is designed to use the of_get_mac_address api
+			only if efuse-mac is 0. When efuse-mac is 0, the MAC
+			address is obtained from local-mac-address. If this
+			attribute is not present, then the driver will use a
+			random MAC address.
+- "netcp-device label":	phandle to the device specification for each of NetCP
+			sub-module attached to this interface.
+
+Example binding:
+
+netcp: netcp@2090000 {
+	reg = <0x2620110 0x8>;
+	reg-names = "efuse";
+	compatible = "ti,netcp-1.0";
+	#address-cells = <1>;
+	#size-cells = <1>;
+	ranges;
+
+	clocks = <&papllclk>, <&clkcpgmac>, <&chipclk12>;
+	dma-coherent;
+	/* big-endian; */
+	dma-id = <0>;
+
+	netcp-devices {
+		#address-cells = <1>;
+		#size-cells = <1>;
+		ranges;
+		gbe@0x2090000 {
+			label = "netcp-gbe";
+			reg = <0x2090000 0xf00>;
+			/* enable-ale; */
+			tx-queue = <648>;
+			tx-channel = <8>;
+
+			interfaces {
+				gbe0: interface-0 {
+					slave-port = <0>;
+					link-interface	= <4>;
+				};
+				gbe1: interface-1 {
+					slave-port = <1>;
+					link-interface	= <4>;
+				};
+			};
+
+			secondary-slave-ports {
+				port-2 {
+					slave-port = <2>;
+					link-interface	= <2>;
+				};
+				port-3 {
+					slave-port = <3>;
+					link-interface	= <2>;
+				};
+			};
+		};
+	};
+
+	netcp-interfaces {
+		interface-0 {
+			rx-channel = <22>;
+			rx-pool = <1024 12>;
+			tx-pool = <1024 12>;
+			rx-queue-depth = <128 128 0 0>;
+			rx-buffer-size = <1518 4096 0 0>;
+			rx-queue = <8704>;
+			tx-completion-queue = <8706>;
+			efuse-mac = <1>;
+			netcp-gbe = <&gbe0>;
+
+		};
+		interface-1 {
+			rx-channel = <23>;
+			rx-pool = <1024 12>;
+			tx-pool = <1024 12>;
+			rx-queue-depth = <128 128 0 0>;
+			rx-buffer-size = <1518 4096 0 0>;
+			rx-queue = <8705>;
+			tx-completion-queue = <8707>;
+			efuse-mac = <0>;
+			local-mac-address = [02 18 31 7e 3e 6f];
+			netcp-gbe = <&gbe1>;
+		};
+	};
+};
-- 
1.7.9.5
