From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] ethtool.h: MDI setting support
Date: Tue, 21 Aug 2012 01:37:50 -0700
Message-ID: <1345538275-1690-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345538275-1690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54114 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221Ab2HUIh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 04:37:58 -0400
In-Reply-To: <1345538275-1690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change modifies the core ethtool struct to allow a driver to
support setting of MDI/MDI-X state for twisted pair wiring.  This
change uses a previously reserved u8 and should not change any
binary compatibility of ethtool.

Also as per Ben Hutchings' suggestion, the capabilities are
stored in a separate byte so the driver can report if it supports
changing settings.

see thread: http://kerneltrap.org/mailarchive/linux-netdev/2010/11/17/6289820/thread

see ethtool patches titled:
ethtool: allow setting MDI-X state

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
Tested-by: Aaron Brown aaron.f.brown@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/ethtool.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 21eff41..fcb4f8e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -45,8 +45,10 @@ struct ethtool_cmd {
 				 * bits) in Mbps. Please use
 				 * ethtool_cmd_speed()/_set() to
 				 * access it */
-	__u8	eth_tp_mdix;
-	__u8	reserved2;
+	__u8	eth_tp_mdix;	/* twisted pair MDI-X status */
+	__u8    eth_tp_mdix_ctrl; /* twisted pair MDI-X control, when set,
+				   * link should be renegotiated if necessary
+				   */
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -1229,10 +1231,13 @@ struct ethtool_ops {
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
1.7.11.4
