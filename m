From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] ethtool: add IPv6 to the NFC API
Date: Tue, 2 Feb 2016 18:49:09 +0000
Message-ID: <56B0FA25.8030708@solarflare.com>
References: <56B0F9A8.7010202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:16384 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933534AbcBBSuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:50:32 -0500
In-Reply-To: <56B0F9A8.7010202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/uapi/linux/ethtool.h | 70 ++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 64 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 57fa390..3b6af3e 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -748,6 +748,56 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+/**
+ * struct ethtool_tcpip6_spec - flow specification for TCP/IPv6 etc.
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @psrc: Source port
+ * @pdst: Destination port
+ * @tos: Type-of-service
+ *
+ * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
+ */
+struct ethtool_tcpip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be16	psrc;
+	__be16	pdst;
+	__u8    tos;
+};
+
+/**
+ * struct ethtool_ah_espip6_spec - flow specification for IPsec/IPv6
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @spi: Security parameters index
+ * @tos: Type-of-service
+ *
+ * This can be used to specify an IPsec transport or tunnel over IPv6.
+ */
+struct ethtool_ah_espip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be32	spi;
+	__u8    tos;
+};
+
+/**
+ * struct ethtool_usrip6_spec - general flow specification for IPv6
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @l4_4_bytes: First 4 bytes of transport (layer 4) header
+ * @tos: Type-of-service
+ * @l4_proto: Transport protocol number (nexthdr after any Extension Headers)
+ */
+struct ethtool_usrip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be32	l4_4_bytes;
+	__u8    tos;
+	__u8    l4_proto;
+};
+
 union ethtool_flow_union {
 	struct ethtool_tcpip4_spec		tcp_ip4_spec;
 	struct ethtool_tcpip4_spec		udp_ip4_spec;
@@ -755,6 +805,12 @@ union ethtool_flow_union {
 	struct ethtool_ah_espip4_spec		ah_ip4_spec;
 	struct ethtool_ah_espip4_spec		esp_ip4_spec;
 	struct ethtool_usrip4_spec		usr_ip4_spec;
+	struct ethtool_tcpip6_spec		tcp_ip6_spec;
+	struct ethtool_tcpip6_spec		udp_ip6_spec;
+	struct ethtool_tcpip6_spec		sctp_ip6_spec;
+	struct ethtool_ah_espip6_spec		ah_ip6_spec;
+	struct ethtool_ah_espip6_spec		esp_ip6_spec;
+	struct ethtool_usrip6_spec		usr_ip6_spec;
 	struct ethhdr				ether_spec;
 	__u8					hdata[52];
 };
@@ -1367,15 +1423,17 @@ enum ethtool_sfeatures_retval_bits {
 #define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
 #define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
 #define	AH_ESP_V4_FLOW	0x04	/* hash only */
-#define	TCP_V6_FLOW	0x05	/* hash only */
-#define	UDP_V6_FLOW	0x06	/* hash only */
-#define	SCTP_V6_FLOW	0x07	/* hash only */
+#define	TCP_V6_FLOW	0x05	/* hash or spec (tcp_ip6_spec; nfc only) */
+#define	UDP_V6_FLOW	0x06	/* hash or spec (udp_ip6_spec; nfc only) */
+#define	SCTP_V6_FLOW	0x07	/* hash or spec (sctp_ip6_spec; nfc only) */
 #define	AH_ESP_V6_FLOW	0x08	/* hash only */
 #define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
 #define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
-#define	AH_V6_FLOW	0x0b	/* hash only */
-#define	ESP_V6_FLOW	0x0c	/* hash only */
-#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	AH_V6_FLOW	0x0b	/* hash or spec (ah_ip6_spec; nfc only) */
+#define	ESP_V6_FLOW	0x0c	/* hash or spec (esp_ip6_spec; nfc only) */
+#define	IPV4_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	IP_USER_FLOW	IPV4_USER_FLOW
+#define	IPV6_USER_FLOW	0x0e	/* spec only (usr_ip6_spec; nfc only) */
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
