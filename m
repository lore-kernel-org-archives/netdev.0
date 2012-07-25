From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC NET-NEXT PATCH 1/6] ethtool.h: MDI setting support
Date: Wed, 25 Jul 2012 11:00:05 -0700
Message-ID: <20120725180005.9995.50528.stgit@jbrandeb-snb.jf.intel.com>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57819 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab2GYUwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:03 -0400
In-Reply-To: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

 include/linux/ethtool.h |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

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
