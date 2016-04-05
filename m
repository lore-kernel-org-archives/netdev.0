From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: document missing functions
Date: Tue,  5 Apr 2016 11:22:40 -0400
Message-ID: <1459869760-23295-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add description for the missing port_vlan_prepare, port_fdb_prepare,
port_fdb_dump functions in the DSA documentation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/networking/dsa/dsa.txt | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 3b196c3..8ba3369 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -542,6 +542,12 @@ Bridge layer
 Bridge VLAN filtering
 ---------------------
 
+- port_vlan_prepare: bridge layer function invoked when the bridge prepares the
+  configuration of a VLAN on the given port. If the operation is not
+  programmable, this function should return -EOPNOTSUPP to inform the bridge
+  code to fallback to a software implementation. No hardware programmation
+  must be done in this function. See port_vlan_add for this and details.
+
 - port_vlan_add: bridge layer function invoked when a VLAN is configured
   (tagged or untagged) for the given switch port
 
@@ -552,6 +558,12 @@ Bridge VLAN filtering
   function that the driver has to call for each VLAN the given port is a member
   of. A switchdev object is used to carry the VID and bridge flags.
 
+- port_fdb_prepare: bridge layer function invoked when the bridge prepares the
+  installation of a Forwarding Database entry. If the operation is not
+  programmable, this function should return -EOPNOTSUPP to inform the bridge
+  code to fallback to a software implementation. No hardware programmation
+  must be done in this function. See port_fdb_add for this and details.
+
 - port_fdb_add: bridge layer function invoked when the bridge wants to install a
   Forwarding Database entry, the switch hardware should be programmed with the
   specified address in the specified VLAN Id in the forwarding database
@@ -565,6 +577,10 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
   the specified MAC address from the specified VLAN ID if it was mapped into
   this port forwarding database
 
+- port_fdb_dump: bridge layer function invoked with a switchdev callback
+  function that the driver has to call for each MAC address known to be behind
+  the given port. A switchdev object is used to carry the VID and FDB info.
+
 TODO
 ====
 
-- 
2.8.0
