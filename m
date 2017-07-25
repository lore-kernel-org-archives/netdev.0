From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next v2 09/10] net: dsa: lan9303: Added Documentation/networking/dsa/lan9303.txt
Date: Tue, 25 Jul 2017 18:15:52 +0200
Message-ID: <20170725161553.30147-10-privat@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 Documentation/networking/dsa/lan9303.txt | 63 ++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)
 create mode 100644 Documentation/networking/dsa/lan9303.txt

diff --git a/Documentation/networking/dsa/lan9303.txt b/Documentation/networking/dsa/lan9303.txt
new file mode 100644
index 000000000000..ef5b3ca12a29
--- /dev/null
+++ b/Documentation/networking/dsa/lan9303.txt
@@ -0,0 +1,63 @@
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
+
+
+Bridging notes
+==============
+When the user ports are bridged, broadcasts, multicasts and unknown
+frames with unknown destination are flooded by the chip. Therefore SW
+flooding must be disabled by:
+
+   echo 0 > /sys/class/net/p1/brport/broadcast_flood
+   echo 0 > /sys/class/net/p1/brport/multicast_flood
+   echo 0 > /sys/class/net/p1/brport/unicast_flood
+   echo 0 > /sys/class/net/p2/brport/broadcast_flood
+   echo 0 > /sys/class/net/p2/brport/multicast_flood
+   echo 0 > /sys/class/net/p2/brport/unicast_flood
+
-- 
2.11.0
