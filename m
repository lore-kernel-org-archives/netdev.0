From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: replace __constant_{endian} uses in net headers
Date: Wed, 11 Feb 2009 17:15:27 -0800
Message-ID: <1234401327.5566.18.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:22227 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756345AbZBLBPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 20:15:30 -0500
Received: by wf-out-1314.google.com with SMTP id 28so492944wfa.4
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 17:15:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Base versions handle constant folding now.  For headers exposed to
userspace, we must only expose the __ prefixed versions.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/linux/if_pppox.h         |   20 ++++----
 include/linux/if_tunnel.h        |   16 +++---
 include/linux/ncp_no.h           |   26 +++++-----
 include/linux/netdevice.h        |    4 +-
 include/linux/netfilter_bridge.h |    4 +-
 include/linux/pim.h              |    4 +-
 include/linux/sctp.h             |   90 +++++++++++++++++++-------------------
 include/linux/tcp.h              |   20 ++++----
 include/net/inet_ecn.h           |    4 +-
 include/net/ip_vs.h              |    4 +-
 include/net/ipv6.h               |    4 +-
 include/net/ipx.h                |    2 +-
 include/net/transp_v6.h          |    2 +-
 include/rdma/ib_verbs.h          |    2 +-
 14 files changed, 101 insertions(+), 101 deletions(-)

diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 30c88b2..90b5fae 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -95,16 +95,16 @@ struct pppoe_tag {
 } __attribute ((packed));
 
 /* Tag identifiers */
-#define PTT_EOL		__constant_htons(0x0000)
-#define PTT_SRV_NAME	__constant_htons(0x0101)
-#define PTT_AC_NAME	__constant_htons(0x0102)
-#define PTT_HOST_UNIQ	__constant_htons(0x0103)
-#define PTT_AC_COOKIE	__constant_htons(0x0104)
-#define PTT_VENDOR 	__constant_htons(0x0105)
-#define PTT_RELAY_SID	__constant_htons(0x0110)
-#define PTT_SRV_ERR     __constant_htons(0x0201)
-#define PTT_SYS_ERR  	__constant_htons(0x0202)
-#define PTT_GEN_ERR  	__constant_htons(0x0203)
+#define PTT_EOL		__cpu_to_be16(0x0000)
+#define PTT_SRV_NAME	__cpu_to_be16(0x0101)
+#define PTT_AC_NAME	__cpu_to_be16(0x0102)
+#define PTT_HOST_UNIQ	__cpu_to_be16(0x0103)
+#define PTT_AC_COOKIE	__cpu_to_be16(0x0104)
+#define PTT_VENDOR 	__cpu_to_be16(0x0105)
+#define PTT_RELAY_SID	__cpu_to_be16(0x0110)
+#define PTT_SRV_ERR     __cpu_to_be16(0x0201)
+#define PTT_SYS_ERR  	__cpu_to_be16(0x0202)
+#define PTT_GEN_ERR  	__cpu_to_be16(0x0203)
 
 struct pppoe_hdr {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 82c4362..5a9aae4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -16,14 +16,14 @@
 #define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
 #define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
 
-#define GRE_CSUM	__constant_htons(0x8000)
-#define GRE_ROUTING	__constant_htons(0x4000)
-#define GRE_KEY		__constant_htons(0x2000)
-#define GRE_SEQ		__constant_htons(0x1000)
-#define GRE_STRICT	__constant_htons(0x0800)
-#define GRE_REC		__constant_htons(0x0700)
-#define GRE_FLAGS	__constant_htons(0x00F8)
-#define GRE_VERSION	__constant_htons(0x0007)
+#define GRE_CSUM	__cpu_to_be16(0x8000)
+#define GRE_ROUTING	__cpu_to_be16(0x4000)
+#define GRE_KEY		__cpu_to_be16(0x2000)
+#define GRE_SEQ		__cpu_to_be16(0x1000)
+#define GRE_STRICT	__cpu_to_be16(0x0800)
+#define GRE_REC		__cpu_to_be16(0x0700)
+#define GRE_FLAGS	__cpu_to_be16(0x00F8)
+#define GRE_VERSION	__cpu_to_be16(0x0007)
 
 struct ip_tunnel_parm
 {
diff --git a/include/linux/ncp_no.h b/include/linux/ncp_no.h
index f56a696..cddaa48 100644
--- a/include/linux/ncp_no.h
+++ b/include/linux/ncp_no.h
@@ -2,18 +2,18 @@
 #define _NCP_NO
 
 /* these define the attribute byte as seen by NCP */
-#define aRONLY			(__constant_cpu_to_le32(1))
-#define aHIDDEN			(__constant_cpu_to_le32(2))
-#define aSYSTEM			(__constant_cpu_to_le32(4))
-#define aEXECUTE		(__constant_cpu_to_le32(8))
-#define aDIR			(__constant_cpu_to_le32(0x10))
-#define aARCH			(__constant_cpu_to_le32(0x20))
-#define aSHARED			(__constant_cpu_to_le32(0x80))
-#define aDONTSUBALLOCATE	(__constant_cpu_to_le32(1L<<11))
-#define aTRANSACTIONAL		(__constant_cpu_to_le32(1L<<12))
-#define aPURGE			(__constant_cpu_to_le32(1L<<16))
-#define aRENAMEINHIBIT		(__constant_cpu_to_le32(1L<<17))
-#define aDELETEINHIBIT		(__constant_cpu_to_le32(1L<<18))
-#define aDONTCOMPRESS		(__constant_cpu_to_le32(1L<<27))
+#define aRONLY			(__cpu_to_le32(1))
+#define aHIDDEN			(__cpu_to_le32(2))
+#define aSYSTEM			(__cpu_to_le32(4))
+#define aEXECUTE		(__cpu_to_le32(8))
+#define aDIR			(__cpu_to_le32(0x10))
+#define aARCH			(__cpu_to_le32(0x20))
+#define aSHARED			(__cpu_to_le32(0x80))
+#define aDONTSUBALLOCATE	(__cpu_to_le32(1L<<11))
+#define aTRANSACTIONAL		(__cpu_to_le32(1L<<12))
+#define aPURGE			(__cpu_to_le32(1L<<16))
+#define aRENAMEINHIBIT		(__cpu_to_le32(1L<<17))
+#define aDELETEINHIBIT		(__cpu_to_le32(1L<<18))
+#define aDONTCOMPRESS		(__cpu_to_le32(1L<<27))
 
 #endif /* _NCP_NO */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 355662a..bd8b4ca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1863,7 +1863,7 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 
 		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
 			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-			    skb->protocol == __constant_htons(ETH_P_ARP))
+			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
 				return 0;
 
 			if (master->priv_flags & IFF_MASTER_ALB) {
@@ -1872,7 +1872,7 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 					return 0;
 			}
 			if (master->priv_flags & IFF_MASTER_8023AD &&
-			    skb->protocol == __constant_htons(ETH_P_SLOW))
+			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
 				return 0;
 
 			return 1;
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 499aa93..f8105e5 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -59,9 +59,9 @@ static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_8021Q):
+	case __cpu_to_be16(ETH_P_8021Q):
 		return VLAN_HLEN;
-	case __constant_htons(ETH_P_PPP_SES):
+	case __cpu_to_be16(ETH_P_PPP_SES):
 		return PPPOE_SES_HLEN;
 	default:
 		return 0;
diff --git a/include/linux/pim.h b/include/linux/pim.h
index 1ba0661..252bf66 100644
--- a/include/linux/pim.h
+++ b/include/linux/pim.h
@@ -4,14 +4,14 @@
 #include <asm/byteorder.h>
 
 /* Message types - V1 */
-#define PIM_V1_VERSION		__constant_htonl(0x10000000)
+#define PIM_V1_VERSION		cpu_to_be32(0x10000000)
 #define PIM_V1_REGISTER		1
 
 /* Message types - V2 */
 #define PIM_VERSION		2
 #define PIM_REGISTER		1
 
-#define PIM_NULL_REGISTER	__constant_htonl(0x40000000)
+#define PIM_NULL_REGISTER	cpu_to_be32(0x40000000)
 
 /* PIMv2 register message header layout (ietf-draft-idmr-pimvsm-v2-00.ps */
 struct pimreghdr
diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 8ba1c32..bd50b37 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -172,35 +172,35 @@ typedef struct sctp_paramhdr {
 typedef enum {
 
 	/* RFC 2960 Section 3.3.5 */
-	SCTP_PARAM_HEARTBEAT_INFO		= __constant_htons(1),
+	SCTP_PARAM_HEARTBEAT_INFO		= cpu_to_be16(1),
 	/* RFC 2960 Section 3.3.2.1 */
-	SCTP_PARAM_IPV4_ADDRESS			= __constant_htons(5),
-	SCTP_PARAM_IPV6_ADDRESS			= __constant_htons(6),
-	SCTP_PARAM_STATE_COOKIE			= __constant_htons(7),
-	SCTP_PARAM_UNRECOGNIZED_PARAMETERS	= __constant_htons(8),
-	SCTP_PARAM_COOKIE_PRESERVATIVE		= __constant_htons(9),
-	SCTP_PARAM_HOST_NAME_ADDRESS		= __constant_htons(11),
-	SCTP_PARAM_SUPPORTED_ADDRESS_TYPES	= __constant_htons(12),
-	SCTP_PARAM_ECN_CAPABLE			= __constant_htons(0x8000),
+	SCTP_PARAM_IPV4_ADDRESS			= cpu_to_be16(5),
+	SCTP_PARAM_IPV6_ADDRESS			= cpu_to_be16(6),
+	SCTP_PARAM_STATE_COOKIE			= cpu_to_be16(7),
+	SCTP_PARAM_UNRECOGNIZED_PARAMETERS	= cpu_to_be16(8),
+	SCTP_PARAM_COOKIE_PRESERVATIVE		= cpu_to_be16(9),
+	SCTP_PARAM_HOST_NAME_ADDRESS		= cpu_to_be16(11),
+	SCTP_PARAM_SUPPORTED_ADDRESS_TYPES	= cpu_to_be16(12),
+	SCTP_PARAM_ECN_CAPABLE			= cpu_to_be16(0x8000),
 
 	/* AUTH Extension Section 3 */
-	SCTP_PARAM_RANDOM			= __constant_htons(0x8002),
-	SCTP_PARAM_CHUNKS			= __constant_htons(0x8003),
-	SCTP_PARAM_HMAC_ALGO			= __constant_htons(0x8004),
+	SCTP_PARAM_RANDOM			= cpu_to_be16(0x8002),
+	SCTP_PARAM_CHUNKS			= cpu_to_be16(0x8003),
+	SCTP_PARAM_HMAC_ALGO			= cpu_to_be16(0x8004),
 
 	/* Add-IP: Supported Extensions, Section 4.2 */
-	SCTP_PARAM_SUPPORTED_EXT	= __constant_htons(0x8008),
+	SCTP_PARAM_SUPPORTED_EXT	= cpu_to_be16(0x8008),
 
 	/* PR-SCTP Sec 3.1 */
-	SCTP_PARAM_FWD_TSN_SUPPORT	= __constant_htons(0xc000),
+	SCTP_PARAM_FWD_TSN_SUPPORT	= cpu_to_be16(0xc000),
 
 	/* Add-IP Extension. Section 3.2 */
-	SCTP_PARAM_ADD_IP		= __constant_htons(0xc001),
-	SCTP_PARAM_DEL_IP		= __constant_htons(0xc002),
-	SCTP_PARAM_ERR_CAUSE		= __constant_htons(0xc003),
-	SCTP_PARAM_SET_PRIMARY		= __constant_htons(0xc004),
-	SCTP_PARAM_SUCCESS_REPORT	= __constant_htons(0xc005),
-	SCTP_PARAM_ADAPTATION_LAYER_IND = __constant_htons(0xc006),
+	SCTP_PARAM_ADD_IP		= cpu_to_be16(0xc001),
+	SCTP_PARAM_DEL_IP		= cpu_to_be16(0xc002),
+	SCTP_PARAM_ERR_CAUSE		= cpu_to_be16(0xc003),
+	SCTP_PARAM_SET_PRIMARY		= cpu_to_be16(0xc004),
+	SCTP_PARAM_SUCCESS_REPORT	= cpu_to_be16(0xc005),
+	SCTP_PARAM_ADAPTATION_LAYER_IND = cpu_to_be16(0xc006),
 
 } sctp_param_t; /* enum */
 
@@ -212,13 +212,13 @@ typedef enum {
  *
  */
 typedef enum {
-	SCTP_PARAM_ACTION_DISCARD     = __constant_htons(0x0000),
-	SCTP_PARAM_ACTION_DISCARD_ERR = __constant_htons(0x4000),
-	SCTP_PARAM_ACTION_SKIP        = __constant_htons(0x8000),
-	SCTP_PARAM_ACTION_SKIP_ERR    = __constant_htons(0xc000),
+	SCTP_PARAM_ACTION_DISCARD     = cpu_to_be16(0x0000),
+	SCTP_PARAM_ACTION_DISCARD_ERR = cpu_to_be16(0x4000),
+	SCTP_PARAM_ACTION_SKIP        = cpu_to_be16(0x8000),
+	SCTP_PARAM_ACTION_SKIP_ERR    = cpu_to_be16(0xc000),
 } sctp_param_action_t;
 
-enum { SCTP_PARAM_ACTION_MASK = __constant_htons(0xc000), };
+enum { SCTP_PARAM_ACTION_MASK = cpu_to_be16(0xc000), };
 
 /* RFC 2960 Section 3.3.1 Payload Data (DATA) (0) */
 
@@ -457,17 +457,17 @@ typedef struct sctp_operr_chunk {
  */
 typedef enum {
 
-	SCTP_ERROR_NO_ERROR	   = __constant_htons(0x00),
-	SCTP_ERROR_INV_STRM	   = __constant_htons(0x01),
-	SCTP_ERROR_MISS_PARAM 	   = __constant_htons(0x02),
-	SCTP_ERROR_STALE_COOKIE	   = __constant_htons(0x03),
-	SCTP_ERROR_NO_RESOURCE 	   = __constant_htons(0x04),
-	SCTP_ERROR_DNS_FAILED      = __constant_htons(0x05),
-	SCTP_ERROR_UNKNOWN_CHUNK   = __constant_htons(0x06),
-	SCTP_ERROR_INV_PARAM       = __constant_htons(0x07),
-	SCTP_ERROR_UNKNOWN_PARAM   = __constant_htons(0x08),
-	SCTP_ERROR_NO_DATA         = __constant_htons(0x09),
-	SCTP_ERROR_COOKIE_IN_SHUTDOWN = __constant_htons(0x0a),
+	SCTP_ERROR_NO_ERROR	   = cpu_to_be16(0x00),
+	SCTP_ERROR_INV_STRM	   = cpu_to_be16(0x01),
+	SCTP_ERROR_MISS_PARAM 	   = cpu_to_be16(0x02),
+	SCTP_ERROR_STALE_COOKIE	   = cpu_to_be16(0x03),
+	SCTP_ERROR_NO_RESOURCE 	   = cpu_to_be16(0x04),
+	SCTP_ERROR_DNS_FAILED      = cpu_to_be16(0x05),
+	SCTP_ERROR_UNKNOWN_CHUNK   = cpu_to_be16(0x06),
+	SCTP_ERROR_INV_PARAM       = cpu_to_be16(0x07),
+	SCTP_ERROR_UNKNOWN_PARAM   = cpu_to_be16(0x08),
+	SCTP_ERROR_NO_DATA         = cpu_to_be16(0x09),
+	SCTP_ERROR_COOKIE_IN_SHUTDOWN = cpu_to_be16(0x0a),
 
 
 	/* SCTP Implementation Guide:
@@ -476,9 +476,9 @@ typedef enum {
 	 *  13  Protocol Violation
 	 */
 
-	SCTP_ERROR_RESTART         = __constant_htons(0x0b),
-	SCTP_ERROR_USER_ABORT      = __constant_htons(0x0c),
-	SCTP_ERROR_PROTO_VIOLATION = __constant_htons(0x0d),
+	SCTP_ERROR_RESTART         = cpu_to_be16(0x0b),
+	SCTP_ERROR_USER_ABORT      = cpu_to_be16(0x0c),
+	SCTP_ERROR_PROTO_VIOLATION = cpu_to_be16(0x0d),
 
 	/* ADDIP Section 3.3  New Error Causes
 	 *
@@ -493,11 +493,11 @@ typedef enum {
 	 * 0x0103          Association Aborted due to illegal ASCONF-ACK
 	 * 0x0104          Request refused - no authorization.
 	 */
-	SCTP_ERROR_DEL_LAST_IP	= __constant_htons(0x0100),
-	SCTP_ERROR_RSRC_LOW	= __constant_htons(0x0101),
-	SCTP_ERROR_DEL_SRC_IP	= __constant_htons(0x0102),
-	SCTP_ERROR_ASCONF_ACK   = __constant_htons(0x0103),
-	SCTP_ERROR_REQ_REFUSED	= __constant_htons(0x0104),
+	SCTP_ERROR_DEL_LAST_IP	= cpu_to_be16(0x0100),
+	SCTP_ERROR_RSRC_LOW	= cpu_to_be16(0x0101),
+	SCTP_ERROR_DEL_SRC_IP	= cpu_to_be16(0x0102),
+	SCTP_ERROR_ASCONF_ACK   = cpu_to_be16(0x0103),
+	SCTP_ERROR_REQ_REFUSED	= cpu_to_be16(0x0104),
 
 	/* AUTH Section 4.  New Error Cause
 	 *
@@ -509,7 +509,7 @@ typedef enum {
 	 * --------------------------------------------------------------
 	 * 0x0105          Unsupported HMAC Identifier
 	 */
-	 SCTP_ERROR_UNSUP_HMAC	= __constant_htons(0x0105)
+	 SCTP_ERROR_UNSUP_HMAC	= cpu_to_be16(0x0105)
 } sctp_error_t;
 
 
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fe77e14..25a2b84 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -69,16 +69,16 @@ union tcp_word_hdr {
 #define tcp_flag_word(tp) ( ((union tcp_word_hdr *)(tp))->words [3]) 
 
 enum { 
-	TCP_FLAG_CWR = __constant_htonl(0x00800000), 
-	TCP_FLAG_ECE = __constant_htonl(0x00400000), 
-	TCP_FLAG_URG = __constant_htonl(0x00200000), 
-	TCP_FLAG_ACK = __constant_htonl(0x00100000), 
-	TCP_FLAG_PSH = __constant_htonl(0x00080000), 
-	TCP_FLAG_RST = __constant_htonl(0x00040000), 
-	TCP_FLAG_SYN = __constant_htonl(0x00020000), 
-	TCP_FLAG_FIN = __constant_htonl(0x00010000),
-	TCP_RESERVED_BITS = __constant_htonl(0x0F000000),
-	TCP_DATA_OFFSET = __constant_htonl(0xF0000000)
+	TCP_FLAG_CWR = __cpu_to_be32(0x00800000), 
+	TCP_FLAG_ECE = __cpu_to_be32(0x00400000), 
+	TCP_FLAG_URG = __cpu_to_be32(0x00200000), 
+	TCP_FLAG_ACK = __cpu_to_be32(0x00100000), 
+	TCP_FLAG_PSH = __cpu_to_be32(0x00080000), 
+	TCP_FLAG_RST = __cpu_to_be32(0x00040000), 
+	TCP_FLAG_SYN = __cpu_to_be32(0x00020000), 
+	TCP_FLAG_FIN = __cpu_to_be32(0x00010000),
+	TCP_RESERVED_BITS = __cpu_to_be32(0x0F000000),
+	TCP_DATA_OFFSET = __cpu_to_be32(0xF0000000)
 }; 
 
 /* TCP socket options */
diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 7040a78..9b5d08f 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -113,12 +113,12 @@ static inline void ipv6_copy_dscp(unsigned int dscp, struct ipv6hdr *inner)
 static inline int INET_ECN_set_ce(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
 		if (skb->network_header + sizeof(struct iphdr) <= skb->tail)
 			return IP_ECN_set_ce(ip_hdr(skb));
 		break;
 
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IPV6):
 		if (skb->network_header + sizeof(struct ipv6hdr) <= skb->tail)
 			return IP6_ECN_set_ce(ipv6_hdr(skb));
 		break;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ab9b003..bbae1e8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -184,8 +184,8 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 /*
  *      The port number of FTP service (in network order).
  */
-#define FTPPORT  __constant_htons(21)
-#define FTPDATA  __constant_htons(20)
+#define FTPPORT  cpu_to_be16(21)
+#define FTPDATA  cpu_to_be16(20)
 
 /*
  *      TCP State Values
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6d5b58a..c1f16fc 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -196,8 +196,8 @@ struct ip6_flowlabel
 	struct net		*fl_net;
 };
 
-#define IPV6_FLOWINFO_MASK	__constant_htonl(0x0FFFFFFF)
-#define IPV6_FLOWLABEL_MASK	__constant_htonl(0x000FFFFF)
+#define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
+#define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
 
 struct ipv6_fl_socklist
 {
diff --git a/include/net/ipx.h b/include/net/ipx.h
index 4cc0b4e..a14121d 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -27,7 +27,7 @@ struct ipx_address {
 
 struct ipxhdr {
 	__be16			ipx_checksum __attribute__ ((packed));
-#define IPX_NO_CHECKSUM	__constant_htons(0xFFFF)
+#define IPX_NO_CHECKSUM	cpu_to_be16(0xFFFF)
 	__be16			ipx_pktsize __attribute__ ((packed));
 	__u8			ipx_tctrl;
 	__u8			ipx_type;
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 876b6f2..bfb240c 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -46,7 +46,7 @@ extern int			datagram_send_ctl(struct net *net,
 						  struct ipv6_txoptions *opt,
 						  int *hlimit, int *tclass);
 
-#define		LOOPBACK4_IPV6		__constant_htonl(0x7f000006)
+#define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
 
 /*
  *	address family specific functions
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 936e333..c179318 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -388,7 +388,7 @@ enum {
 	IB_MULTICAST_QPN = 0xffffff
 };
 
-#define IB_LID_PERMISSIVE	__constant_htons(0xFFFF)
+#define IB_LID_PERMISSIVE	cpu_to_be16(0xFFFF)
 
 enum ib_ah_flags {
 	IB_AH_GRH	= 1
-- 
1.6.2.rc0.218.gde7c



