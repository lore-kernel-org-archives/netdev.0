From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] drivers/net: fixup comments after "Future-proof tunnel offload handlers"
Date: Mon, 11 Jul 2016 13:12:28 +0200
Message-ID: <a1439b9645eec067ebe03a4e2d5228ed78f0e85e.1468235257.git.sd@queasysnail.net>
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbcGKLNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 07:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some comments weren't updated to reflect the renaming of ndo's and the
change of arguments.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 8 ++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 8 ++------
 drivers/net/geneve.c                            | 4 ++--
 drivers/net/vxlan.c                             | 4 ++--
 4 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index d00cb193da9a..20a5bbe3f536 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -432,9 +432,7 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
 /**
  * fm10k_add_vxlan_port
  * @netdev: network interface device structure
- * @sa_family: Address family of new port
- * @port: port number used for VXLAN
- * @type: Enumerated value specifying udp encapsulation type
+ * @ti: Tunnel endpoint information
  *
  * This function is called when a new VXLAN interface has added a new port
  * number to the range that is currently in use for VXLAN.  The new port
@@ -480,9 +478,7 @@ insert_tail:
 /**
  * fm10k_del_vxlan_port
  * @netdev: network interface device structure
- * @sa_family: Address family of freed port
- * @port: port number used for VXLAN
- * @type: Enumerated value specifying udp encapsulation type
+ * @ti: Tunnel endpoint information
  *
  * This function is called when a new VXLAN interface has freed a port
  * number from the range that is currently in use for VXLAN.  The freed
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 468fa9ddfa06..18a222e99ed9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8781,9 +8781,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 /**
  * ixgbe_add_vxlan_port - Get notifications about VXLAN ports that come up
  * @dev: The port's netdev
- * @sa_family: Socket Family that VXLAN is notifiying us about
- * @port: New UDP port number that VXLAN started listening to
- * @type: Enumerated type specifying UDP tunnel type
+ * @ti: Tunnel endpoint information
  **/
 static void ixgbe_add_vxlan_port(struct net_device *dev,
 				 struct udp_tunnel_info *ti)
@@ -8818,9 +8816,7 @@ static void ixgbe_add_vxlan_port(struct net_device *dev,
 /**
  * ixgbe_del_vxlan_port - Get notifications about VXLAN ports that go away
  * @dev: The port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: UDP port number that VXLAN stopped listening to
- * @type: Enumerated type specifying UDP tunnel type
+ * @ti: Tunnel endpoint information
  **/
 static void ixgbe_del_vxlan_port(struct net_device *dev,
 				 struct udp_tunnel_info *ti)
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index aa61708bea69..c37f551b3de6 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1129,9 +1129,9 @@ static struct device_type geneve_type = {
 	.name = "geneve",
 };
 
-/* Calls the ndo_add_udp_enc_port of the caller in order to
+/* Calls the ndo_udp_tunnel_add of the caller in order to
  * supply the listening GENEVE udp ports. Callers are expected
- * to implement the ndo_add_udp_enc_port.
+ * to implement the ndo_udp_tunnel_add.
  */
 static void geneve_push_rx_ports(struct net_device *dev)
 {
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index abb9cd2df9e9..f6609cc608dc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2475,9 +2475,9 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_udp_enc_port of the caller in order to
+/* Calls the ndo_udp_tunnel_add of the caller in order to
  * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_udp_enc_port.
+ * to implement the ndo_udp_tunnel_add.
  */
 static void vxlan_push_rx_ports(struct net_device *dev)
 {
-- 
2.9.0
