From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v5 ethtool 1/2] ethtool: Support for configurable RSS hash key
Date: Mon, 21 Apr 2014 15:38:50 +0530
Message-ID: <4889cd71-7686-46fa-ab25-fc766fc5bcd2@CMEXHTCAS2.ad.emulex.com>
References: <1398074931-13346-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:16876 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbaDUKJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 06:09:34 -0400
In-Reply-To: <1398074931-13346-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch adds new structure ethtool_rxfh definition for ETHTOOL_GRSSH
and ETHTOOL_SRSSH commands.

Kernel tree: net-next

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool-copy.h |   36 ++++++++++++++++++++++++++++++++++--
 1 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..2477673 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -630,6 +630,35 @@ struct ethtool_rxfh_indir {
 };
 
 /**
+ * struct ethtool_rxfh - command to get/set RX flow hash indir or/and hash key.
+ * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
+ * @rss_context: RSS context identifier.
+ * @indir_size: On entry, the array size of the user buffer, which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the array size of the hardware
+ *		indirection table.
+ * @key_size:	On entry, the array size of the user buffer in bytes,
+ *		which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
+ * @rsvd:	Reserved for future extensions.
+ * @rss_config: RX ring/queue index for each hash value i.e., indirection table
+ *		of size @indir_size followed by hash key of size @key_size.
+ *
+ * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only the
+ * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of 0xDEADBEEF
+ * means that indir table setting is not requested and a @indir_size of zero
+ * means the indir table should be reset to default values.  This last feature
+ * is not supported by the original implementations.
+ */
+struct ethtool_rxfh {
+	__u32   cmd;
+	__u32   rss_context;
+	__u32   indir_size;
+	__u32   key_size;
+	__u32	rsvd[2];
+	__u32   rss_config[0];
+};
+
+/**
  * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow field values to match (dependent on @flow_type)
@@ -901,6 +930,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
+#define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
+#define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -993,8 +1025,8 @@ enum ethtool_sfeatures_retval_bits {
 #define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
-#define XCVR_INTERNAL		0x00
-#define XCVR_EXTERNAL		0x01
+#define XCVR_INTERNAL		0x00 /* PHY and MAC are in the same package */
+#define XCVR_EXTERNAL		0x01 /* PHY and MAC are in different packages */
 #define XCVR_DUMMY1		0x02
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
-- 
1.7.1
