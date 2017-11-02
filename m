From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next] net: dsa: lan9303: Added Documentation/networking/dsa/lan9303.txt
Date: Thu,  2 Nov 2017 10:20:58 +0100
Message-ID: <20171102092058.3782-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>

Provide a rough overview of the state of the driver. And explain that the
driver operates in two modes: bridged and port-separated.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 Documentation/networking/dsa/lan9303.txt | 37 ++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)
 create mode 100644 Documentation/networking/dsa/lan9303.txt

diff --git a/Documentation/networking/dsa/lan9303.txt b/Documentation/networking/dsa/lan9303.txt
new file mode 100644
index 000000000000..ec28683d107d
--- /dev/null
+++ b/Documentation/networking/dsa/lan9303.txt
@@ -0,0 +1,37 @@
+LAN9303 Ethernet switch driver
+==============================
+
+The LAN9303 is a three port 10/100 ethernet switch with integrated phys for the
+two external ethernet ports. The third port is an RMII/MII interface to a host
+master network interface (e.g. fixed link).
+
+
+Driver details
+==============
+
+The driver is implemented as a DSA driver, see
+Documentation/networking/dsa/dsa.txt.
+
+See Documentation/devicetree/bindings/net/dsa/lan9303.txt for device tree
+binding.
+
+The LAN9303 can be managed both via MDIO and I2C, both supported by this driver.
+
+At startup the driver configures the device to provide two separate network
+interfaces (which is the default state of a DSA device). Due to HW limitations,
+no HW MAC learning takes place in this mode.
+
+When both user ports are joined to the same bridge, the normal HW MAC learning
+is enabled. This means that unicast traffic is forwarded in HW. Broadcast and
+multicast is flooded in HW. STP is also supported in this mode. The driver
+support fdb/mdb operations as well, meaning IGMP snooping is supported.
+
+If one of the user ports leave the bridge, the ports goes back to the initial
+separated operation.
+
+
+Driver limitations
+==================
+
+ - Support for VLAN filtering is not implemented
+ - The HW does not support VLAN-specific fdb entries
-- 
2.11.0
