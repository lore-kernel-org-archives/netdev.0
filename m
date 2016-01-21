From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH] ethtool: add IPv6 to the NFC API
Date: Thu, 21 Jan 2016 19:14:49 +0000
Message-ID: <56A12E29.7000507@solarflare.com>
References: <1453317771.3734.68.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:52705 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752311AbcAUUAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 15:00:30 -0500
In-Reply-To: <1453317771.3734.68.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
Haven't yet tried to write the ethtool client end of this (or a driver
implementation), but does it look reasonable?

 include/uapi/linux/ethtool.h | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 57fa390..74bef53 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -748,6 +748,24 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+/**
+ * struct ethtool_ip6_spec - general flow specification for IPv6
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @l4_4_bytes: First 4 bytes of transport (layer 4) header
+ * @spi: Security parameters index, for %AH_V6_FLOW and %ESP_V6_FLOW
+ * @tos: Type-of-service
+ * @proto: Transport protocol number, for %IP6_USER_FLOW
+ */
+struct ethtool_ip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be32	l4_4_bytes;
+	__be32	spi;
+	__u8	tos;
+	__u8	proto;
+};
+
 union ethtool_flow_union {
 	struct ethtool_tcpip4_spec		tcp_ip4_spec;
 	struct ethtool_tcpip4_spec		udp_ip4_spec;
@@ -755,6 +773,7 @@ union ethtool_flow_union {
 	struct ethtool_ah_espip4_spec		ah_ip4_spec;
 	struct ethtool_ah_espip4_spec		esp_ip4_spec;
 	struct ethtool_usrip4_spec		usr_ip4_spec;
+	struct ethtool_ip6_spec			ip6_spec;
 	struct ethhdr				ether_spec;
 	__u8					hdata[52];
 };
@@ -1367,18 +1386,19 @@ enum ethtool_sfeatures_retval_bits {
 #define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
 #define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
 #define	AH_ESP_V4_FLOW	0x04	/* hash only */
-#define	TCP_V6_FLOW	0x05	/* hash only */
-#define	UDP_V6_FLOW	0x06	/* hash only */
-#define	SCTP_V6_FLOW	0x07	/* hash only */
+#define	TCP_V6_FLOW	0x05	/* hash or spec (ip6_spec) */
+#define	UDP_V6_FLOW	0x06	/* hash or spec (ip6_spec) */
+#define	SCTP_V6_FLOW	0x07	/* hash or spec (ip6_spec) */
 #define	AH_ESP_V6_FLOW	0x08	/* hash only */
 #define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
 #define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
-#define	AH_V6_FLOW	0x0b	/* hash only */
-#define	ESP_V6_FLOW	0x0c	/* hash only */
+#define	AH_V6_FLOW	0x0b	/* hash or spec (ip6_spec) */
+#define	ESP_V6_FLOW	0x0c	/* hash or spec (ip6_spec) */
 #define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
+#define	IP6_USER_FLOW	0x13	/* spec only (ip6_spec) */
 /* Flag to enable additional fields in struct ethtool_rx_flow_spec */
 #define	FLOW_EXT	0x80000000
 #define	FLOW_MAC_EXT	0x40000000
