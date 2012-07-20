From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 1/2] ethtool.h: implement new MDI-X set defines
Date: Thu, 19 Jul 2012 23:25:23 -0700
Message-ID: <1342765524-29711-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32340 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab2GTGZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 02:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

These changes implement the kernel side of the interface
for allowing drivers to set MDI-X state on twisted pair.

Changes implemented as suggested by Ben Hutchings, thanks Ben!

see ethtool patches titled:
ethtool: allow setting MDI-X state

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool-copy.h |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 0e90e9b..6625eff 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -42,8 +42,10 @@ struct ethtool_cmd {
 				 * bits) in Mbps. Please use
 				 * ethtool_cmd_speed()/_set() to
 				 * access it */
-	__u8	eth_tp_mdix;
-	__u8	reserved2;
+	__u8	eth_tp_mdix;	/* twisted pair MDI-X status */
+	__u8	eth_tp_mdix_ctrl; /* twisted pair MDI-X control, when set,
+				   * link should be renegotiated if necessary
+				   */
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -989,10 +991,13 @@ enum ethtool_sfeatures_retval_bits {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
-/* Mode MDI or MDI-X */
-#define ETH_TP_MDI_INVALID	0x00
-#define ETH_TP_MDI		0x01
-#define ETH_TP_MDI_X		0x02
+/* MDI or MDI-X status/control - if MDI/MDI_X/AUTO is set then
+ * the driver is required to renegotiate link
+ */
+#define ETH_TP_MDI_INVALID	0x00 /* status: unknown; control: unsupported */
+#define ETH_TP_MDI		0x01 /* status: MDI;     control: force MDI */
+#define ETH_TP_MDI_X		0x02 /* status: MDI-X;   control: force MDI-X */
+#define ETH_TP_MDI_AUTO		0x03 /*                  control: auto-select */
 
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
-- 
1.7.10.4
