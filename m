From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v2 ethtool 1/2] ethtool: Support for configurable RSS hash key
Date: Sat, 22 Feb 2014 17:11:45 +0530
Message-ID: <07968156-8dbe-4b69-bf7a-eed482186422@CMEXHTCAS1.ad.emulex.com>
References: <1393069306-11378-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21253 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaBVLlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 06:41:39 -0500
In-Reply-To: <1393069306-11378-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch adds new structure ethtool_rxfh definition for ETHTOOL_GRSSH
and ETHTOOL_SRSSH commands.
---
 ethtool-copy.h |   42 +++++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..d7c7dad 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -611,22 +611,30 @@ struct ethtool_rxnfc {
 
 
 /**
- * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
- * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
- * @size: On entry, the array size of the user buffer, which may be zero.
- *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
- *	indirection table.
- * @ring_index: RX ring/queue index for each hash value
+ * struct ethtool_rxfh - command to get or set RX flow hash indirection or/and
+ * hash key.
+ * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
+ * @indir_size: On entry, the array size of the user buffer, which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the array size of the hardware
+ *		indirection table.
+ * @key_size:	On entry, the array size of the user buffer in bytes,
+ *		which may be zero.
+ *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
+ * @rsvd:	Reserved for future extensions.
+ * @rss_config: RX ring/queue index for each hash value or/and hash key
+ *		respectively.
  *
- * For %ETHTOOL_GRXFHINDIR, a @size of zero means that only the size
- * should be returned.  For %ETHTOOL_SRXFHINDIR, a @size of zero means
- * the table should be reset to default values.  This last feature
+ * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only the
+ * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of zero means
+ * the indir table should be reset to default values.  This last feature
  * is not supported by the original implementations.
  */
-struct ethtool_rxfh_indir {
-	__u32	cmd;
-	__u32	size;
-	__u32	ring_index[0];
+struct ethtool_rxfh {
+	__u32   cmd;
+	__u32   indir_size;
+	__u32   key_size;
+	__u32	rsvd[3];
+	__u32   rss_config[0];
 };
 
 /**
@@ -885,8 +893,8 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
 #define ETHTOOL_GRXNTUPLE	0x00000036 /* deprecated */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
-#define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
-#define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_GRSSH		0x00000038 /* Get RX flow hash configuration */
+#define ETHTOOL_SRSSH		0x00000039 /* Set RX flow hash configuration */
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
@@ -993,8 +1001,8 @@ enum ethtool_sfeatures_retval_bits {
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
