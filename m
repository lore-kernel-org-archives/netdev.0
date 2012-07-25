From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC ETHTOOL PATCH 1/2] ethtool.h: implement new MDI-X set defines
Date: Wed, 25 Jul 2012 10:53:03 -0700
Message-ID: <20120725175303.9839.74257.stgit@jbrandeb-snb.jf.intel.com>
References: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467Ab2GYUwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:02 -0400
In-Reply-To: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes implement the kernel side of the interface
for allowing drivers to set MDI-X state on twisted pair.

Changes implemented as suggested by Ben Hutchings, thanks Ben!

see ethtool patches titled:
ethtool: allow setting MDI-X state

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---

 ethtool-copy.h |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 9e26a76..1e2673e 100644
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
@@ -945,10 +947,13 @@ enum ethtool_sfeatures_retval_bits {
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
