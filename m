From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 09/13] net: dsa: lan9303: Added
 Documentation/networking/dsa/lan9303.txt
Date: Tue, 11 Jul 2017 13:48:25 +0200
Message-ID: <60633305145b42d898e3cacd76216705@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 Documentation/networking/dsa/lan9303.txt | 48 ++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)
 create mode 100644 Documentation/networking/dsa/lan9303.txt

diff --git a/Documentation/networking/dsa/lan9303.txt b/Documentation/networking/dsa/lan9303.txt
new file mode 100644
index 000000000000..1fd72ff4b492
--- /dev/null
+++ b/Documentation/networking/dsa/lan9303.txt
@@ -0,0 +1,48 @@
+LAN9303 Ethernet switch driver
+==============================
+
+The LAN9303 is a three port 10/100 ethernet switch with integrated phys
+for the two external ethernet ports. The third port is an RMII/MII
+interface to a host master network interface (e.g. fixed link).
+
+
+Driver details
+==============
+
+The driver is implemented as a DSA driver, see
+Documentation/networking/dsa/dsa.txt.
+
+See Documentation/devicetree/bindings/net/dsa/lan9303.txt for device
+tree binding.
+
+The LAN9303 can be managed both via MDIO and I2C, both supported by this
+driver.
+
+At startup the driver configures the device to provide two separate
+network interfaces (which is the default state of a DSA device).
+
+When both user ports are joined to the same bridge, the normal
+HW MAC learning is enabled. This means that unicast traffic is forwarded
+in HW. STP is also supported in this mode.
+
+If one of the user ports leave the bridge,
+the ports goes back to the initial separated operation.
+
+The driver implements the port_fdb_xxx/port_mdb_xxx methods.
+
+
+Sysfs nodes
+===========
+
+When a user port is enabled, the driver creates sysfs directory
+/sys/class/net/xxx/lan9303 with the following files:
+
+ - swe_bcst_throt (RW): Set/get 6.4.7 Broadcast Storm Control
+      Throttle Level for the port. Accesses the corresponding bits of
+      the SWE_BCST_THROT register (13.4.3.23).
+
+
+Driver limitations
+==================
+
+ - No support for VLAN
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
