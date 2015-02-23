From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e/i40evf: restrict VC opcodes to their initial values
Date: Sun, 22 Feb 2015 19:25:35 -0800
Message-ID: <1424661944-1779-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Nicholas Nunley <nicholas.d.nunley@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:60786 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341AbbBWD0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:26:12 -0500
In-Reply-To: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Nunley <nicholas.d.nunley@intel.com>

Until the time a more robust versioning scheme is needed/implemented all
established virtual channel opcode values should remain consistent between
updates to the opcode enum.

This patch repositions I40E_VIRTCHNL_OP_CONFIG_RSS to the end of the enum. In
its current position this opcode displaces the initial value of
I40E_VIRTCHNL_OP_EVENT and will cause PF/VF compatibility issues.

Going forward the expectation is either:
	a) All future opcode additions will be added as the last element of the
	enum. Once VF drivers start making use of the new commands the virtual
	channel version will need to be incremented and drivers will need to
	implement a simple version check whereby VF drivers can only load on
	PFs with a >= version.
	b) or, if needed, design and implement a more complicated API
	negotiation capability.

In either case PF drivers should always maintain backwards compatibility with
earlier VF driver versions.

Change-ID: Ie245daa09a231b6680ed793d648bdcc76caefe58
Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 42 +++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 42 +++++++++++------------
 2 files changed, 40 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 61dd1b18..2d20af2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -59,31 +59,29 @@
  * of the virtchnl_msg structure.
  */
 enum i40e_virtchnl_ops {
-/* VF sends req. to pf for the following
- * ops.
+/* The PF sends status change events to VFs using
+ * the I40E_VIRTCHNL_OP_EVENT opcode.
+ * VFs send requests to the PF using the other ops.
  */
 	I40E_VIRTCHNL_OP_UNKNOWN = 0,
 	I40E_VIRTCHNL_OP_VERSION = 1, /* must ALWAYS be 1 */
-	I40E_VIRTCHNL_OP_RESET_VF,
-	I40E_VIRTCHNL_OP_GET_VF_RESOURCES,
-	I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE,
-	I40E_VIRTCHNL_OP_CONFIG_RX_QUEUE,
-	I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES,
-	I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP,
-	I40E_VIRTCHNL_OP_ENABLE_QUEUES,
-	I40E_VIRTCHNL_OP_DISABLE_QUEUES,
-	I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS,
-	I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS,
-	I40E_VIRTCHNL_OP_ADD_VLAN,
-	I40E_VIRTCHNL_OP_DEL_VLAN,
-	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE,
-	I40E_VIRTCHNL_OP_GET_STATS,
-	I40E_VIRTCHNL_OP_FCOE,
-	I40E_VIRTCHNL_OP_CONFIG_RSS,
-/* PF sends status change events to vfs using
- * the following op.
- */
-	I40E_VIRTCHNL_OP_EVENT,
+	I40E_VIRTCHNL_OP_RESET_VF = 2,
+	I40E_VIRTCHNL_OP_GET_VF_RESOURCES = 3,
+	I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE = 4,
+	I40E_VIRTCHNL_OP_CONFIG_RX_QUEUE = 5,
+	I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES = 6,
+	I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP = 7,
+	I40E_VIRTCHNL_OP_ENABLE_QUEUES = 8,
+	I40E_VIRTCHNL_OP_DISABLE_QUEUES = 9,
+	I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS = 10,
+	I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS = 11,
+	I40E_VIRTCHNL_OP_ADD_VLAN = 12,
+	I40E_VIRTCHNL_OP_DEL_VLAN = 13,
+	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE = 14,
+	I40E_VIRTCHNL_OP_GET_STATS = 15,
+	I40E_VIRTCHNL_OP_FCOE = 16,
+	I40E_VIRTCHNL_OP_EVENT = 17,
+	I40E_VIRTCHNL_OP_CONFIG_RSS = 18,
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index e0c8208..59f62f0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -59,31 +59,29 @@
  * of the virtchnl_msg structure.
  */
 enum i40e_virtchnl_ops {
-/* VF sends req. to pf for the following
- * ops.
+/* The PF sends status change events to VFs using
+ * the I40E_VIRTCHNL_OP_EVENT opcode.
+ * VFs send requests to the PF using the other ops.
  */
 	I40E_VIRTCHNL_OP_UNKNOWN = 0,
 	I40E_VIRTCHNL_OP_VERSION = 1, /* must ALWAYS be 1 */
-	I40E_VIRTCHNL_OP_RESET_VF,
-	I40E_VIRTCHNL_OP_GET_VF_RESOURCES,
-	I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE,
-	I40E_VIRTCHNL_OP_CONFIG_RX_QUEUE,
-	I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES,
-	I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP,
-	I40E_VIRTCHNL_OP_ENABLE_QUEUES,
-	I40E_VIRTCHNL_OP_DISABLE_QUEUES,
-	I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS,
-	I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS,
-	I40E_VIRTCHNL_OP_ADD_VLAN,
-	I40E_VIRTCHNL_OP_DEL_VLAN,
-	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE,
-	I40E_VIRTCHNL_OP_GET_STATS,
-	I40E_VIRTCHNL_OP_FCOE,
-	I40E_VIRTCHNL_OP_CONFIG_RSS,
-/* PF sends status change events to vfs using
- * the following op.
- */
-	I40E_VIRTCHNL_OP_EVENT,
+	I40E_VIRTCHNL_OP_RESET_VF = 2,
+	I40E_VIRTCHNL_OP_GET_VF_RESOURCES = 3,
+	I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE = 4,
+	I40E_VIRTCHNL_OP_CONFIG_RX_QUEUE = 5,
+	I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES = 6,
+	I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP = 7,
+	I40E_VIRTCHNL_OP_ENABLE_QUEUES = 8,
+	I40E_VIRTCHNL_OP_DISABLE_QUEUES = 9,
+	I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS = 10,
+	I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS = 11,
+	I40E_VIRTCHNL_OP_ADD_VLAN = 12,
+	I40E_VIRTCHNL_OP_DEL_VLAN = 13,
+	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE = 14,
+	I40E_VIRTCHNL_OP_GET_STATS = 15,
+	I40E_VIRTCHNL_OP_FCOE = 16,
+	I40E_VIRTCHNL_OP_EVENT = 17,
+	I40E_VIRTCHNL_OP_CONFIG_RSS = 18,
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
-- 
1.9.3
