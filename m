From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] ethtool-copy.h: sync with net-next
Date: Wed, 30 Jun 2010 16:12:20 +0100
Message-ID: <1277910740.2082.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8535 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab0F3PMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 11:12:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This "sync" assumes that "ethtool: Add support for control of RX flow
hash indirection" has been merged into net-next-2.6.

Ben.

 ethtool-copy.h |   46 +++++++++++++++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c5eb680..0b3aea2 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -36,7 +36,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 						__u32 speed)
 {
 
@@ -44,7 +44,7 @@ static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
+static __inline__ __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -384,6 +384,15 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+struct ethtool_rxfh_indir {
+	__u32	cmd;
+	/* On entry, this is the array size of the user buffer.  On
+	 * return from ETHTOOL_GRXFHINDIR, this is the array size of
+	 * the hardware indirection table. */
+	__u32	size;
+	__u32	ring_index[0];	/* ring/queue index for each hash value */
+};
+
 struct ethtool_rx_ntuple_flow_spec {
 	__u32		 flow_type;
 	union {
@@ -425,6 +434,7 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
 #define ETHTOOL_SSET		0x00000002 /* Set settings. */
@@ -468,21 +478,23 @@ struct ethtool_flash {
 #define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
 #define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
 
-#define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
-#define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+#define ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
+#define ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
 #define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
 #define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
-#define	ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
-#define	ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
-#define	ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
-#define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
-#define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
-#define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
-#define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
-#define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-#define	ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define	ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
-#define	ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
+#define ETHTOOL_GRXRINGS	0x0000002d /* Get RX rings available for LB */
+#define ETHTOOL_GRXCLSRLCNT	0x0000002e /* Get RX class rule count */
+#define ETHTOOL_GRXCLSRULE	0x0000002f /* Get RX classification rule */
+#define ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
+#define ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
+#define ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
+#define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
+#define ETHTOOL_RESET		0x00000034 /* Reset hardware */
+#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
+#define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
+#define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -602,8 +614,8 @@ struct ethtool_flash {
 #define	AH_V6_FLOW	0x0b
 #define	ESP_V6_FLOW	0x0c
 #define	IP_USER_FLOW	0x0d
-#define IPV4_FLOW       0x10
-#define IPV6_FLOW       0x11
+#define	IPV4_FLOW	0x10
+#define	IPV6_FLOW	0x11
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

