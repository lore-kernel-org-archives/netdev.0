From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [RFC PATCH  ethtool 1/2] ethtool-copy.h: sync with net
Date: Tue, 25 Oct 2016 14:39:21 -0700
Message-ID: <1477431562-38455-2-git-send-email-vidya@cumulusnetworks.com>
Cc: roees@mellanox.com, dustin@cumulusnetworks.com,
        roopa@cumulusnetworks.com, aviadr@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org,
        linville@tuxdriver.com, saeedm@mellanox.com, galp@mellanox.com,
        odedw@mellanox.com, ariela@mellanox.com, tzahio@mellanox.com,
        ddecotig@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35720 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941972AbcJYVja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 17:39:30 -0400
Received: by mail-pf0-f171.google.com with SMTP id s8so125881501pfj.2
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 14:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Sending out this review as RFC to get early feedback
on fec options and output changes as changes to kernel uapi
to ethtool is under review on netdev currently and might
change based on review..
http://patchwork.ozlabs.org/patch/686293/

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 ethtool-copy.h | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 51 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 70748f5..ff3f4f0 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1222,6 +1222,51 @@ struct ethtool_per_queue_op {
 	char	data[];
 };
 
+/**
+ * struct ethtool_fecparam - Ethernet forward error correction(fec) parameters
+ * @cmd: Command number = %ETHTOOL_GFECPARAM or %ETHTOOL_SFECPARAM
+ * @autoneg: Flag to enable autonegotiation of fec modes(rs,baser)
+ *          (D44:47 of base link code word)
+ * @fec: Bitmask of supported FEC modes
+ * @rsvd: Reserved for future extensions. i.e FEC bypass feature.
+ *
+ * Drivers should reject a non-zero setting of @autoneg when
+ * autoneogotiation is disabled (or not supported) for the link.
+ *
+ * If @autoneg is non-zero, the MAC is configured to enable one of
+ * the supported FEC modes according to the result of autonegotiation.
+ * Otherwise, it is configured directly based on the @fec parameter
+ */
+struct ethtool_fecparam {
+	__u32   cmd;
+	__u32   autoneg;
+	/* bitmask of FEC modes */
+	__u32   fec;
+	__u32   reserved;
+};
+
+/**
+ * enum ethtool_fec_config_bits - flags definition of ethtool_fec_configuration
+ * @ETHTOOL_FEC_NONE: FEC mode configuration is not supported
+ * @ETHTOOL_FEC_AUTO: Default/Best FEC mode provided by driver
+ * @ETHTOOL_FEC_OFF: No FEC Mode
+ * @ETHTOOL_FEC_RS: Reed-Solomon Forward Error Detection mode
+ * @ETHTOOL_FEC_BASER: Base-R/Reed-Solomon Forward Error Detection mode
+ */
+enum ethtool_fec_config_bits {
+	ETHTOOL_FEC_NONE_BIT,
+	ETHTOOL_FEC_AUTO_BIT,
+	ETHTOOL_FEC_OFF_BIT,
+	ETHTOOL_FEC_RS_BIT,
+	ETHTOOL_FEC_BASER_BIT,
+};
+
+#define ETHTOOL_FEC_NONE		(1 << ETHTOOL_FEC_NONE_BIT)
+#define ETHTOOL_FEC_AUTO		(1 << ETHTOOL_FEC_AUTO_BIT)
+#define ETHTOOL_FEC_OFF			(1 << ETHTOOL_FEC_OFF_BIT)
+#define ETHTOOL_FEC_RS			(1 << ETHTOOL_FEC_RS_BIT)
+#define ETHTOOL_FEC_BASER		(1 << ETHTOOL_FEC_BASER_BIT)
+
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* DEPRECATED, Get settings.
 					    * Please use ETHTOOL_GLINKSETTINGS
@@ -1313,6 +1358,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 
+#define ETHTOOL_GFECPARAM	0x0000004e /* Get FEC settings */
+#define ETHTOOL_SFECPARAM	0x0000004f /* Set FEC settings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1367,7 +1414,9 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	= 44,
 	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	= 45,
 	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	= 46,
-
+	ETHTOOL_LINK_MODE_FEC_NONE_BIT		= 47,
+	ETHTOOL_LINK_MODE_FEC_RS_BIT		= 48,
+	ETHTOOL_LINK_MODE_FEC_BASER_BIT		= 49,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1376,7 +1425,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+	  = ETHTOOL_LINK_MODE_FEC_BASER_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.1.4
