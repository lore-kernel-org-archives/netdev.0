From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: use __packed annotation
Date: Thu, 03 Jun 2010 00:20:09 +0200
Message-ID: <1275517209.29413.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63100 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895Ab0FBWUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 18:20:16 -0400
Received: by wwb28 with SMTP id 28so3309740wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 15:20:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cleanup patch.

Use new __packed annotation in net/ and include/
(except netfilter)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/if_ether.h   |    2 
 include/linux/if_fddi.h    |    8 +--
 include/linux/if_frad.h    |    2 
 include/linux/if_hippi.h   |    8 +--
 include/linux/if_pppox.h   |    8 +--
 include/linux/ipv6.h       |    4 -
 include/linux/isdnif.h     |    2 
 include/linux/mISDNif.h    |    2 
 include/linux/nbd.h        |    2 
 include/linux/ncp.h        |   10 ++--
 include/linux/ncp_fs_sb.h  |   14 +++---
 include/linux/phonet.h     |    4 -
 include/linux/rds.h        |   12 ++---
 include/linux/sctp.h       |   80 +++++++++++++++++------------------
 include/linux/wlp.h        |   22 ++++-----
 include/net/dn_dev.h       |    8 +--
 include/net/dn_nsp.h       |   16 +++----
 include/net/ip6_tunnel.h   |    2 
 include/net/ipx.h          |    8 +--
 include/net/mip6.h         |    2 
 include/net/ndisc.h        |    2 
 include/net/sctp/structs.h |    4 -
 include/rxrpc/packet.h     |    8 +--
 net/bluetooth/bnep/bnep.h  |    8 +--
 net/compat.c               |    6 +-
 net/iucv/iucv.c            |   14 +++---
 net/mac80211/cfg.c         |    2 
 net/mac80211/ieee80211_i.h |    2 
 net/mac80211/rx.c          |    2 
 net/sctp/sm_make_chunk.c   |    2 
 30 files changed, 133 insertions(+), 133 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index bed7a46..c831467 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -119,7 +119,7 @@ struct ethhdr {
 	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
 	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
 	__be16		h_proto;		/* packet type ID field	*/
-} __attribute__((packed));
+} __packed;
 
 #ifdef __KERNEL__
 #include <linux/skbuff.h>
diff --git a/include/linux/if_fddi.h b/include/linux/if_fddi.h
index 5459c5c..9947c39 100644
--- a/include/linux/if_fddi.h
+++ b/include/linux/if_fddi.h
@@ -67,7 +67,7 @@ struct fddi_8022_1_hdr {
 	__u8	dsap;					/* destination service access point */
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl;					/* control byte #1 */
-} __attribute__ ((packed));
+} __packed;
 
 /* Define 802.2 Type 2 header */
 struct fddi_8022_2_hdr {
@@ -75,7 +75,7 @@ struct fddi_8022_2_hdr {
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl_1;					/* control byte #1 */
 	__u8	ctrl_2;					/* control byte #2 */
-} __attribute__ ((packed));
+} __packed;
 
 /* Define 802.2 SNAP header */
 #define FDDI_K_OUI_LEN	3
@@ -85,7 +85,7 @@ struct fddi_snap_hdr {
 	__u8	ctrl;					/* always 0x03 */
 	__u8	oui[FDDI_K_OUI_LEN];	/* organizational universal id */
 	__be16	ethertype;				/* packet type ID field */
-} __attribute__ ((packed));
+} __packed;
 
 /* Define FDDI LLC frame header */
 struct fddihdr {
@@ -98,7 +98,7 @@ struct fddihdr {
 		struct fddi_8022_2_hdr		llc_8022_2;
 		struct fddi_snap_hdr		llc_snap;
 		} hdr;
-} __attribute__ ((packed));
+} __packed;
 
 #ifdef __KERNEL__
 #include <linux/netdevice.h>
diff --git a/include/linux/if_frad.h b/include/linux/if_frad.h
index 80b3a10..191ee08 100644
--- a/include/linux/if_frad.h
+++ b/include/linux/if_frad.h
@@ -135,7 +135,7 @@ struct frhdr
    __be16 PID;
 
 #define IP_NLPID pad 
-} __attribute__((packed));
+} __packed;
 
 /* see RFC 1490 for the definition of the following */
 #define FRAD_I_UI		0x03
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index 8d038eb..5fe5f30 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -104,7 +104,7 @@ struct hippi_fp_hdr {
 	__be32		fixed;
 #endif
 	__be32		d2_size;
-} __attribute__ ((packed));
+} __packed;
 
 struct hippi_le_hdr {
 #if defined (__BIG_ENDIAN_BITFIELD)
@@ -129,7 +129,7 @@ struct hippi_le_hdr {
 	__u8		daddr[HIPPI_ALEN];
 	__u16		locally_administered;
 	__u8		saddr[HIPPI_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 #define HIPPI_OUI_LEN	3
 /*
@@ -142,12 +142,12 @@ struct hippi_snap_hdr {
 	__u8	ctrl;			/* always 0x03 */
 	__u8	oui[HIPPI_OUI_LEN];	/* organizational universal id (zero)*/
 	__be16	ethertype;		/* packet type ID field */
-} __attribute__ ((packed));
+} __packed;
 
 struct hippi_hdr {
 	struct hippi_fp_hdr	fp;
 	struct hippi_le_hdr	le;
 	struct hippi_snap_hdr	snap;
-} __attribute__ ((packed));
+} __packed;
 
 #endif	/* _LINUX_IF_HIPPI_H */
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index a6577af..2d54b53 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -59,7 +59,7 @@ struct sockaddr_pppox {
        union{ 
                struct pppoe_addr       pppoe; 
        }sa_addr; 
-}__attribute__ ((packed)); 
+} __packed; 
 
 /* The use of the above union isn't viable because the size of this
  * struct must stay fixed over time -- applications use sizeof(struct
@@ -70,7 +70,7 @@ struct sockaddr_pppol2tp {
 	sa_family_t     sa_family;      /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tp_addr pppol2tp;
-}__attribute__ ((packed));
+} __packed;
 
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
@@ -79,7 +79,7 @@ struct sockaddr_pppol2tpv3 {
 	sa_family_t     sa_family;      /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpv3_addr pppol2tp;
-} __attribute__ ((packed));
+} __packed;
 
 /*********************************************************************
  *
@@ -129,7 +129,7 @@ struct pppoe_hdr {
 	__be16 sid;
 	__be16 length;
 	struct pppoe_tag tag[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* Length of entire PPPoE + PPP header */
 #define PPPOE_SES_HLEN	8
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 99e1ab7..940e215 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -58,7 +58,7 @@ struct ipv6_opt_hdr {
 	/* 
 	 * TLV encoded option data follows.
 	 */
-} __attribute__ ((packed));	/* required for some archs */
+} __packed;	/* required for some archs */
 
 #define ipv6_destopt_hdr ipv6_opt_hdr
 #define ipv6_hopopt_hdr  ipv6_opt_hdr
@@ -99,7 +99,7 @@ struct ipv6_destopt_hao {
 	__u8			type;
 	__u8			length;
 	struct in6_addr		addr;
-} __attribute__ ((__packed__));
+} __packed;
 
 /*
  *	IPv6 fixed header
diff --git a/include/linux/isdnif.h b/include/linux/isdnif.h
index b9b5a68..b8c23f8 100644
--- a/include/linux/isdnif.h
+++ b/include/linux/isdnif.h
@@ -317,7 +317,7 @@ typedef struct T30_s {
 	__u8 r_scantime;
 	__u8 r_id[FAXIDLEN];
 	__u8 r_code;
-} __attribute__((packed)) T30_s;
+} __packed T30_s;
 
 #define ISDN_TTY_FAX_CONN_IN	0
 #define ISDN_TTY_FAX_CONN_OUT	1
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 78c3bed..b5e7f22 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -251,7 +251,7 @@
 struct mISDNhead {
 	unsigned int	prim;
 	unsigned int	id;
-}  __attribute__((packed));
+}  __packed;
 
 #define MISDN_HEADER_LEN	sizeof(struct mISDNhead)
 #define MAX_DATA_SIZE		2048
diff --git a/include/linux/nbd.h b/include/linux/nbd.h
index 155719d..bb58854 100644
--- a/include/linux/nbd.h
+++ b/include/linux/nbd.h
@@ -88,7 +88,7 @@ struct nbd_request {
 	char handle[8];
 	__be64 from;
 	__be32 len;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * This is the reply packet that nbd-server sends back to the client after
diff --git a/include/linux/ncp.h b/include/linux/ncp.h
index 99f0ade..3ace837 100644
--- a/include/linux/ncp.h
+++ b/include/linux/ncp.h
@@ -27,7 +27,7 @@ struct ncp_request_header {
 	__u8 conn_high;
 	__u8 function;
 	__u8 data[0];
-} __attribute__((packed));
+} __packed;
 
 #define NCP_REPLY                (0x3333)
 #define NCP_WATCHDOG		 (0x3E3E)
@@ -42,7 +42,7 @@ struct ncp_reply_header {
 	__u8 completion_code;
 	__u8 connection_state;
 	__u8 data[0];
-} __attribute__((packed));
+} __packed;
 
 #define NCP_VOLNAME_LEN (16)
 #define NCP_NUMBER_OF_VOLUMES (256)
@@ -158,7 +158,7 @@ struct nw_info_struct {
 #ifdef __KERNEL__
 	struct nw_nfs_info nfs;
 #endif
-} __attribute__((packed));
+} __packed;
 
 /* modify mask - use with MODIFY_DOS_INFO structure */
 #define DM_ATTRIBUTES		  (cpu_to_le32(0x02))
@@ -190,12 +190,12 @@ struct nw_modify_dos_info {
 	__u16 inheritanceGrantMask;
 	__u16 inheritanceRevokeMask;
 	__u32 maximumSpace;
-} __attribute__((packed));
+} __packed;
 
 struct nw_search_sequence {
 	__u8 volNumber;
 	__u32 dirBase;
 	__u32 sequence;
-} __attribute__((packed));
+} __packed;
 
 #endif				/* _LINUX_NCP_H */
diff --git a/include/linux/ncp_fs_sb.h b/include/linux/ncp_fs_sb.h
index 5ec9ca6..8da05bc 100644
--- a/include/linux/ncp_fs_sb.h
+++ b/include/linux/ncp_fs_sb.h
@@ -104,13 +104,13 @@ struct ncp_server {
 
 		unsigned int state;		/* STREAM only: receiver state */
 		struct {
-			__u32 magic __attribute__((packed));
-			__u32 len __attribute__((packed));
-			__u16 type __attribute__((packed));
-			__u16 p1 __attribute__((packed));
-			__u16 p2 __attribute__((packed));
-			__u16 p3 __attribute__((packed));
-			__u16 type2 __attribute__((packed));
+			__u32 magic __packed;
+			__u32 len __packed;
+			__u16 type __packed;
+			__u16 p1 __packed;
+			__u16 p2 __packed;
+			__u16 p3 __packed;
+			__u16 type2 __packed;
 		} buf;				/* STREAM only: temporary buffer */
 		unsigned char* ptr;		/* STREAM only: pointer to data */
 		size_t len;			/* STREAM only: length of data to receive */
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index e5126cf..24426c3 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -56,7 +56,7 @@ struct phonethdr {
 	__be16	pn_length;
 	__u8	pn_robj;
 	__u8	pn_sobj;
-} __attribute__((packed));
+} __packed;
 
 /* Common Phonet payload header */
 struct phonetmsg {
@@ -98,7 +98,7 @@ struct sockaddr_pn {
 	__u8 spn_dev;
 	__u8 spn_resource;
 	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(sa_family_t) - 3];
-} __attribute__ ((packed));
+} __packed;
 
 /* Well known address */
 #define PN_DEV_PC	0x10
diff --git a/include/linux/rds.h b/include/linux/rds.h
index cab4994..24bce3d 100644
--- a/include/linux/rds.h
+++ b/include/linux/rds.h
@@ -100,7 +100,7 @@
 struct rds_info_counter {
 	u_int8_t	name[32];
 	u_int64_t	value;
-} __attribute__((packed));
+} __packed;
 
 #define RDS_INFO_CONNECTION_FLAG_SENDING	0x01
 #define RDS_INFO_CONNECTION_FLAG_CONNECTING	0x02
@@ -115,7 +115,7 @@ struct rds_info_connection {
 	__be32		faddr;
 	u_int8_t	transport[TRANSNAMSIZ];		/* null term ascii */
 	u_int8_t	flags;
-} __attribute__((packed));
+} __packed;
 
 struct rds_info_flow {
 	__be32		laddr;
@@ -123,7 +123,7 @@ struct rds_info_flow {
 	u_int32_t	bytes;
 	__be16		lport;
 	__be16		fport;
-} __attribute__((packed));
+} __packed;
 
 #define RDS_INFO_MESSAGE_FLAG_ACK               0x01
 #define RDS_INFO_MESSAGE_FLAG_FAST_ACK          0x02
@@ -136,7 +136,7 @@ struct rds_info_message {
 	__be16		lport;
 	__be16		fport;
 	u_int8_t	flags;
-} __attribute__((packed));
+} __packed;
 
 struct rds_info_socket {
 	u_int32_t	sndbuf;
@@ -146,7 +146,7 @@ struct rds_info_socket {
 	__be16		connected_port;
 	u_int32_t	rcvbuf;
 	u_int64_t	inum;
-} __attribute__((packed));
+} __packed;
 
 struct rds_info_tcp_socket {
 	__be32          local_addr;
@@ -158,7 +158,7 @@ struct rds_info_tcp_socket {
 	u_int32_t       last_sent_nxt;
 	u_int32_t       last_expected_una;
 	u_int32_t       last_seen_una;
-} __attribute__((packed));
+} __packed;
 
 #define RDS_IB_GID_LEN	16
 struct rds_info_rdma_connection {
diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index c20d3ce..c11a287 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -61,7 +61,7 @@ typedef struct sctphdr {
 	__be16 dest;
 	__be32 vtag;
 	__le32 checksum;
-} __attribute__((packed)) sctp_sctphdr_t;
+} __packed sctp_sctphdr_t;
 
 #ifdef __KERNEL__
 #include <linux/skbuff.h>
@@ -77,7 +77,7 @@ typedef struct sctp_chunkhdr {
 	__u8 type;
 	__u8 flags;
 	__be16 length;
-} __attribute__((packed)) sctp_chunkhdr_t;
+} __packed sctp_chunkhdr_t;
 
 
 /* Section 3.2.  Chunk Type Values.
@@ -167,7 +167,7 @@ enum { SCTP_CHUNK_FLAG_T = 0x01 };
 typedef struct sctp_paramhdr {
 	__be16 type;
 	__be16 length;
-} __attribute__((packed)) sctp_paramhdr_t;
+} __packed sctp_paramhdr_t;
 
 typedef enum {
 
@@ -228,12 +228,12 @@ typedef struct sctp_datahdr {
 	__be16 ssn;
 	__be32 ppid;
 	__u8  payload[0];
-} __attribute__((packed)) sctp_datahdr_t;
+} __packed sctp_datahdr_t;
 
 typedef struct sctp_data_chunk {
         sctp_chunkhdr_t chunk_hdr;
         sctp_datahdr_t  data_hdr;
-} __attribute__((packed)) sctp_data_chunk_t;
+} __packed sctp_data_chunk_t;
 
 /* DATA Chuck Specific Flags */
 enum {
@@ -259,78 +259,78 @@ typedef struct sctp_inithdr {
 	__be16 num_inbound_streams;
 	__be32 initial_tsn;
 	__u8  params[0];
-} __attribute__((packed)) sctp_inithdr_t;
+} __packed sctp_inithdr_t;
 
 typedef struct sctp_init_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_inithdr_t init_hdr;
-} __attribute__((packed)) sctp_init_chunk_t;
+} __packed sctp_init_chunk_t;
 
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
 typedef struct sctp_ipv4addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in_addr  addr;
-} __attribute__((packed)) sctp_ipv4addr_param_t;
+} __packed sctp_ipv4addr_param_t;
 
 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in6_addr addr;
-} __attribute__((packed)) sctp_ipv6addr_param_t;
+} __packed sctp_ipv6addr_param_t;
 
 /* Section 3.3.2.1 Cookie Preservative (9) */
 typedef struct sctp_cookie_preserve_param {
 	sctp_paramhdr_t param_hdr;
 	__be32          lifespan_increment;
-} __attribute__((packed)) sctp_cookie_preserve_param_t;
+} __packed sctp_cookie_preserve_param_t;
 
 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
 	sctp_paramhdr_t param_hdr;
 	uint8_t hostname[0];
-} __attribute__((packed)) sctp_hostname_param_t;
+} __packed sctp_hostname_param_t;
 
 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
 	sctp_paramhdr_t param_hdr;
 	__be16 types[0];
-} __attribute__((packed)) sctp_supported_addrs_param_t;
+} __packed sctp_supported_addrs_param_t;
 
 /* Appendix A. ECN Capable (32768) */
 typedef struct sctp_ecn_capable_param {
 	sctp_paramhdr_t param_hdr;
-} __attribute__((packed)) sctp_ecn_capable_param_t;
+} __packed sctp_ecn_capable_param_t;
 
 /* ADDIP Section 3.2.6 Adaptation Layer Indication */
 typedef struct sctp_adaptation_ind_param {
 	struct sctp_paramhdr param_hdr;
 	__be32 adaptation_ind;
-} __attribute__((packed)) sctp_adaptation_ind_param_t;
+} __packed sctp_adaptation_ind_param_t;
 
 /* ADDIP Section 4.2.7 Supported Extensions Parameter */
 typedef struct sctp_supported_ext_param {
 	struct sctp_paramhdr param_hdr;
 	__u8 chunks[0];
-} __attribute__((packed)) sctp_supported_ext_param_t;
+} __packed sctp_supported_ext_param_t;
 
 /* AUTH Section 3.1 Random */
 typedef struct sctp_random_param {
 	sctp_paramhdr_t param_hdr;
 	__u8 random_val[0];
-} __attribute__((packed)) sctp_random_param_t;
+} __packed sctp_random_param_t;
 
 /* AUTH Section 3.2 Chunk List */
 typedef struct sctp_chunks_param {
 	sctp_paramhdr_t param_hdr;
 	__u8 chunks[0];
-} __attribute__((packed)) sctp_chunks_param_t;
+} __packed sctp_chunks_param_t;
 
 /* AUTH Section 3.3 HMAC Algorithm */
 typedef struct sctp_hmac_algo_param {
 	sctp_paramhdr_t param_hdr;
 	__be16 hmac_ids[0];
-} __attribute__((packed)) sctp_hmac_algo_param_t;
+} __packed sctp_hmac_algo_param_t;
 
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
@@ -342,13 +342,13 @@ typedef sctp_init_chunk_t sctp_initack_chunk_t;
 typedef struct sctp_cookie_param {
 	sctp_paramhdr_t p;
 	__u8 body[0];
-} __attribute__((packed)) sctp_cookie_param_t;
+} __packed sctp_cookie_param_t;
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
 	sctp_paramhdr_t param_hdr;
 	sctp_paramhdr_t unrecognized;
-} __attribute__((packed)) sctp_unrecognized_param_t;
+} __packed sctp_unrecognized_param_t;
 
 
 
@@ -363,7 +363,7 @@ typedef struct sctp_unrecognized_param {
 typedef struct sctp_gap_ack_block {
 	__be16 start;
 	__be16 end;
-} __attribute__((packed)) sctp_gap_ack_block_t;
+} __packed sctp_gap_ack_block_t;
 
 typedef __be32 sctp_dup_tsn_t;
 
@@ -378,12 +378,12 @@ typedef struct sctp_sackhdr {
 	__be16 num_gap_ack_blocks;
 	__be16 num_dup_tsns;
 	sctp_sack_variable_t variable[0];
-} __attribute__((packed)) sctp_sackhdr_t;
+} __packed sctp_sackhdr_t;
 
 typedef struct sctp_sack_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_sackhdr_t sack_hdr;
-} __attribute__((packed)) sctp_sack_chunk_t;
+} __packed sctp_sack_chunk_t;
 
 
 /* RFC 2960.  Section 3.3.5 Heartbeat Request (HEARTBEAT) (4):
@@ -395,12 +395,12 @@ typedef struct sctp_sack_chunk {
 
 typedef struct sctp_heartbeathdr {
 	sctp_paramhdr_t info;
-} __attribute__((packed)) sctp_heartbeathdr_t;
+} __packed sctp_heartbeathdr_t;
 
 typedef struct sctp_heartbeat_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_heartbeathdr_t hb_hdr;
-} __attribute__((packed)) sctp_heartbeat_chunk_t;
+} __packed sctp_heartbeat_chunk_t;
 
 
 /* For the abort and shutdown ACK we must carry the init tag in the
@@ -409,7 +409,7 @@ typedef struct sctp_heartbeat_chunk {
  */
 typedef struct sctp_abort_chunk {
         sctp_chunkhdr_t uh;
-} __attribute__((packed)) sctp_abort_chunk_t;
+} __packed sctp_abort_chunk_t;
 
 
 /* For the graceful shutdown we must carry the tag (in common header)
@@ -417,12 +417,12 @@ typedef struct sctp_abort_chunk {
  */
 typedef struct sctp_shutdownhdr {
 	__be32 cum_tsn_ack;
-} __attribute__((packed)) sctp_shutdownhdr_t;
+} __packed sctp_shutdownhdr_t;
 
 struct sctp_shutdown_chunk_t {
         sctp_chunkhdr_t    chunk_hdr;
         sctp_shutdownhdr_t shutdown_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
 
@@ -430,12 +430,12 @@ typedef struct sctp_errhdr {
 	__be16 cause;
 	__be16 length;
 	__u8  variable[0];
-} __attribute__((packed)) sctp_errhdr_t;
+} __packed sctp_errhdr_t;
 
 typedef struct sctp_operr_chunk {
         sctp_chunkhdr_t chunk_hdr;
 	sctp_errhdr_t   err_hdr;
-} __attribute__((packed)) sctp_operr_chunk_t;
+} __packed sctp_operr_chunk_t;
 
 /* RFC 2960 3.3.10 - Operation Error
  *
@@ -525,7 +525,7 @@ typedef struct sctp_ecnehdr {
 typedef struct sctp_ecne_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_ecnehdr_t ence_hdr;
-} __attribute__((packed)) sctp_ecne_chunk_t;
+} __packed sctp_ecne_chunk_t;
 
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
@@ -537,7 +537,7 @@ typedef struct sctp_cwrhdr {
 typedef struct sctp_cwr_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_cwrhdr_t cwr_hdr;
-} __attribute__((packed)) sctp_cwr_chunk_t;
+} __packed sctp_cwr_chunk_t;
 
 /* PR-SCTP
  * 3.2 Forward Cumulative TSN Chunk Definition (FORWARD TSN)
@@ -588,17 +588,17 @@ typedef struct sctp_cwr_chunk {
 struct sctp_fwdtsn_skip {
 	__be16 stream;
 	__be16 ssn;
-} __attribute__((packed));
+} __packed;
 
 struct sctp_fwdtsn_hdr {
 	__be32 new_cum_tsn;
 	struct sctp_fwdtsn_skip skip[0];
-} __attribute((packed));
+} __packed;
 
 struct sctp_fwdtsn_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_fwdtsn_hdr fwdtsn_hdr;
-} __attribute((packed));
+} __packed;
 
 
 /* ADDIP
@@ -636,17 +636,17 @@ struct sctp_fwdtsn_chunk {
 typedef struct sctp_addip_param {
 	sctp_paramhdr_t	param_hdr;
 	__be32		crr_id;
-} __attribute__((packed)) sctp_addip_param_t;
+} __packed sctp_addip_param_t;
 
 typedef struct sctp_addiphdr {
 	__be32	serial;
 	__u8	params[0];
-} __attribute__((packed)) sctp_addiphdr_t;
+} __packed sctp_addiphdr_t;
 
 typedef struct sctp_addip_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_addiphdr_t addip_hdr;
-} __attribute__((packed)) sctp_addip_chunk_t;
+} __packed sctp_addip_chunk_t;
 
 /* AUTH
  * Section 4.1  Authentication Chunk (AUTH)
@@ -701,11 +701,11 @@ typedef struct sctp_authhdr {
 	__be16 shkey_id;
 	__be16 hmac_id;
 	__u8   hmac[0];
-} __attribute__((packed)) sctp_authhdr_t;
+} __packed sctp_authhdr_t;
 
 typedef struct sctp_auth_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_authhdr_t auth_hdr;
-} __attribute__((packed)) sctp_auth_chunk_t;
+} __packed sctp_auth_chunk_t;
 
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/linux/wlp.h b/include/linux/wlp.h
index ac95ce6..c76fe23 100644
--- a/include/linux/wlp.h
+++ b/include/linux/wlp.h
@@ -300,7 +300,7 @@ struct wlp_ie {
 	__le16 cycle_param;
 	__le16 acw_anchor_addr;
 	u8 wssid_hash_list[];
-} __attribute__((packed));
+} __packed;
 
 static inline int wlp_ie_hash_length(struct wlp_ie *ie)
 {
@@ -324,7 +324,7 @@ static inline void wlp_ie_set_hash_length(struct wlp_ie *ie, int hash_length)
  */
 struct wlp_nonce {
 	u8 data[16];
-} __attribute__((packed));
+} __packed;
 
 /**
  * WLP UUID
@@ -336,7 +336,7 @@ struct wlp_nonce {
  */
 struct wlp_uuid {
 	u8 data[16];
-} __attribute__((packed));
+} __packed;
 
 
 /**
@@ -348,7 +348,7 @@ struct wlp_dev_type {
 	u8 OUI[3];
 	u8 OUIsubdiv;
 	__le16 subID;
-} __attribute__((packed));
+} __packed;
 
 /**
  * WLP frame header
@@ -357,7 +357,7 @@ struct wlp_dev_type {
 struct wlp_frame_hdr {
 	__le16 mux_hdr;			/* WLP_PROTOCOL_ID */
 	enum wlp_frame_type type:8;
-} __attribute__((packed));
+} __packed;
 
 /**
  * WLP attribute field header
@@ -368,7 +368,7 @@ struct wlp_frame_hdr {
 struct wlp_attr_hdr {
 	__le16 type;
 	__le16 length;
-} __attribute__((packed));
+} __packed;
 
 /**
  * Device information commonly used together
@@ -401,13 +401,13 @@ struct wlp_device_info {
 struct wlp_attr_##name {						\
 	struct wlp_attr_hdr hdr;					\
 	type name;							\
-} __attribute__((packed));
+} __packed;
 
 #define wlp_attr_array(type, name)					\
 struct wlp_attr_##name {						\
 	struct wlp_attr_hdr hdr;					\
 	type name[];							\
-} __attribute__((packed));
+} __packed;
 
 /**
  * WLP association attribute fields
@@ -483,7 +483,7 @@ struct wlp_wss_info {
 	struct wlp_attr_accept_enrl accept;
 	struct wlp_attr_wss_sec_status sec_stat;
 	struct wlp_attr_wss_bcast bcast;
-} __attribute__((packed));
+} __packed;
 
 /* WLP WSS Information */
 wlp_attr_array(struct wlp_wss_info, wss_info)
@@ -520,7 +520,7 @@ wlp_attr(u8, wlp_assc_err)
 struct wlp_frame_std_abbrv_hdr {
 	struct wlp_frame_hdr hdr;
 	u8 tag;
-} __attribute__((packed));
+} __packed;
 
 /**
  * WLP association frames
@@ -533,7 +533,7 @@ struct wlp_frame_assoc {
 	struct wlp_attr_version version;
 	struct wlp_attr_msg_type msg_type;
 	u8 attr[];
-} __attribute__((packed));
+} __packed;
 
 /* Ethernet to dev address mapping */
 struct wlp_eda {
diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index 511a459..0916bbf 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -101,7 +101,7 @@ struct dn_short_packet {
 	__le16 dstnode;
 	__le16 srcnode;
 	__u8   forward;
-} __attribute__((packed));
+} __packed;
 
 struct dn_long_packet {
 	__u8   msgflg;
@@ -115,7 +115,7 @@ struct dn_long_packet {
 	__u8   visit_ct;
 	__u8   s_class;
 	__u8   pt;
-} __attribute__((packed));
+} __packed;
 
 /*------------------------- DRP - Routing messages ---------------------*/
 
@@ -132,7 +132,7 @@ struct endnode_hello_message {
 	__u8   mpd;
 	__u8   datalen;
 	__u8   data[2];
-} __attribute__((packed));
+} __packed;
 
 struct rtnode_hello_message {
 	__u8   msgflg;
@@ -144,7 +144,7 @@ struct rtnode_hello_message {
 	__u8   area;
 	__le16  timer;
 	__u8   mpd;
-} __attribute__((packed));
+} __packed;
 
 
 extern void dn_dev_init(void);
diff --git a/include/net/dn_nsp.h b/include/net/dn_nsp.h
index 17d43d2..e43a289 100644
--- a/include/net/dn_nsp.h
+++ b/include/net/dn_nsp.h
@@ -74,18 +74,18 @@ struct nsp_data_seg_msg {
 	__u8   msgflg;
 	__le16 dstaddr;
 	__le16 srcaddr;
-} __attribute__((packed));
+} __packed;
 
 struct nsp_data_opt_msg {
 	__le16 acknum;
 	__le16 segnum;
 	__le16 lsflgs;
-} __attribute__((packed));
+} __packed;
 
 struct nsp_data_opt_msg1 {
 	__le16 acknum;
 	__le16 segnum;
-} __attribute__((packed));
+} __packed;
 
 
 /* Acknowledgment Message (data/other data)                             */
@@ -94,13 +94,13 @@ struct nsp_data_ack_msg {
 	__le16 dstaddr;
 	__le16 srcaddr;
 	__le16 acknum;
-} __attribute__((packed));
+} __packed;
 
 /* Connect Acknowledgment Message */
 struct  nsp_conn_ack_msg {
 	__u8 msgflg;
 	__le16 dstaddr;
-} __attribute__((packed));
+} __packed;
 
 
 /* Connect Initiate/Retransmit Initiate/Connect Confirm */
@@ -117,7 +117,7 @@ struct  nsp_conn_init_msg {
 #define NSP_FC_MASK   0x0c            /* FC type mask         */
 	__u8   info;
 	__le16 segsize;
-} __attribute__((packed));
+} __packed;
 
 /* Disconnect Initiate/Disconnect Confirm */
 struct  nsp_disconn_init_msg {
@@ -125,7 +125,7 @@ struct  nsp_disconn_init_msg {
 	__le16 dstaddr;
 	__le16 srcaddr;
 	__le16 reason;
-} __attribute__((packed));
+} __packed;
 
 
 
@@ -135,7 +135,7 @@ struct  srcobj_fmt {
 	__le16 grpcode;
 	__le16 usrcode;
 	__u8   dlen;
-} __attribute__((packed));
+} __packed;
 
 /*
  * A collection of functions for manipulating the sequence
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fbf9d1c..fc94ec5 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -27,6 +27,6 @@ struct ipv6_tlv_tnl_enc_lim {
 	__u8 type;		/* type-code for option         */
 	__u8 length;		/* option length                */
 	__u8 encap_limit;	/* tunnel encapsulation limit   */
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/include/net/ipx.h b/include/net/ipx.h
index ef51a66..05d7e4a 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -27,9 +27,9 @@ struct ipx_address {
 #define IPX_MAX_PPROP_HOPS 8
 
 struct ipxhdr {
-	__be16			ipx_checksum __attribute__ ((packed));
+	__be16			ipx_checksum __packed;
 #define IPX_NO_CHECKSUM	cpu_to_be16(0xFFFF)
-	__be16			ipx_pktsize __attribute__ ((packed));
+	__be16			ipx_pktsize __packed;
 	__u8			ipx_tctrl;
 	__u8			ipx_type;
 #define IPX_TYPE_UNKNOWN	0x00
@@ -38,8 +38,8 @@ struct ipxhdr {
 #define IPX_TYPE_SPX		0x05	/* SPX protocol */
 #define IPX_TYPE_NCP		0x11	/* $lots for docs on this (SPIT) */
 #define IPX_TYPE_PPROP		0x14	/* complicated flood fill brdcast */
-	struct ipx_address	ipx_dest __attribute__ ((packed));
-	struct ipx_address	ipx_source __attribute__ ((packed));
+	struct ipx_address	ipx_dest __packed;
+	struct ipx_address	ipx_source __packed;
 };
 
 static __inline__ struct ipxhdr *ipx_hdr(struct sk_buff *skb)
diff --git a/include/net/mip6.h b/include/net/mip6.h
index a83ad19..26ba99b 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -39,7 +39,7 @@ struct ip6_mh {
 	__u16	ip6mh_cksum;
 	/* Followed by type specific messages */
 	__u8	data[0];
-} __attribute__ ((__packed__));
+} __packed;
 
 #define IP6_MH_TYPE_BRR		0   /* Binding Refresh Request */
 #define IP6_MH_TYPE_HOTI	1   /* HOTI Message   */
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index f76f22d..895997b 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -82,7 +82,7 @@ struct ra_msg {
 struct nd_opt_hdr {
 	__u8		nd_opt_type;
 	__u8		nd_opt_len;
-} __attribute__((__packed__));
+} __packed;
 
 
 extern int			ndisc_init(void);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4b86011..f9e7473 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -443,7 +443,7 @@ struct sctp_signed_cookie {
 	__u8 signature[SCTP_SECRET_SIZE];
 	__u32 __pad;		/* force sctp_cookie alignment to 64 bits */
 	struct sctp_cookie c;
-} __attribute__((packed));
+} __packed;
 
 /* This is another convenience type to allocate memory for address
  * params for the maximum size and pass such structures around
@@ -488,7 +488,7 @@ typedef struct sctp_sender_hb_info {
 	union sctp_addr daddr;
 	unsigned long sent_at;
 	__u64 hb_nonce;
-} __attribute__((packed)) sctp_sender_hb_info_t;
+} __packed sctp_sender_hb_info_t;
 
 /*
  *  RFC 2960 1.3.2 Sequenced Delivery within Streams
diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index b69e6e1..9b2c308 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -65,7 +65,7 @@ struct rxrpc_header {
 	};
 	__be16		serviceId;	/* service ID */
 
-} __attribute__((packed));
+} __packed;
 
 #define __rxrpc_header_off(X) offsetof(struct rxrpc_header,X)
 
@@ -120,7 +120,7 @@ struct rxrpc_ackpacket {
 #define RXRPC_ACK_TYPE_NACK		0
 #define RXRPC_ACK_TYPE_ACK		1
 
-} __attribute__((packed));
+} __packed;
 
 /*
  * ACK packets can have a further piece of information tagged on the end
@@ -141,7 +141,7 @@ struct rxkad_challenge {
 	__be32		nonce;		/* encrypted random number */
 	__be32		min_level;	/* minimum security level */
 	__be32		__padding;	/* padding to 8-byte boundary */
-} __attribute__((packed));
+} __packed;
 
 /*****************************************************************************/
 /*
@@ -164,7 +164,7 @@ struct rxkad_response {
 
 	__be32		kvno;		/* Kerberos key version number */
 	__be32		ticket_len;	/* Kerberos ticket length  */
-} __attribute__((packed));
+} __packed;
 
 /*****************************************************************************/
 /*
diff --git a/net/bluetooth/bnep/bnep.h b/net/bluetooth/bnep/bnep.h
index 0d9e506..7067254 100644
--- a/net/bluetooth/bnep/bnep.h
+++ b/net/bluetooth/bnep/bnep.h
@@ -86,26 +86,26 @@ struct bnep_setup_conn_req {
 	__u8  ctrl;
 	__u8  uuid_size;
 	__u8  service[0];
-} __attribute__((packed));
+} __packed;
 
 struct bnep_set_filter_req {
 	__u8  type;
 	__u8  ctrl;
 	__be16 len;
 	__u8  list[0];
-} __attribute__((packed));
+} __packed;
 
 struct bnep_control_rsp {
 	__u8  type;
 	__u8  ctrl;
 	__be16 resp;
-} __attribute__((packed));
+} __packed;
 
 struct bnep_ext_hdr {
 	__u8  type;
 	__u8  len;
 	__u8  data[0];
-} __attribute__((packed));
+} __packed;
 
 /* BNEP ioctl defines */
 #define BNEPCONNADD	_IOW('B', 200, int)
diff --git a/net/compat.c b/net/compat.c
index ec24d9e..1cf7590 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -531,7 +531,7 @@ struct compat_group_req {
 	__u32				 gr_interface;
 	struct __kernel_sockaddr_storage gr_group
 		__attribute__ ((aligned(4)));
-} __attribute__ ((packed));
+} __packed;
 
 struct compat_group_source_req {
 	__u32				 gsr_interface;
@@ -539,7 +539,7 @@ struct compat_group_source_req {
 		__attribute__ ((aligned(4)));
 	struct __kernel_sockaddr_storage gsr_source
 		__attribute__ ((aligned(4)));
-} __attribute__ ((packed));
+} __packed;
 
 struct compat_group_filter {
 	__u32				 gf_interface;
@@ -549,7 +549,7 @@ struct compat_group_filter {
 	__u32				 gf_numsrc;
 	struct __kernel_sockaddr_storage gf_slist[1]
 		__attribute__ ((aligned(4)));
-} __attribute__ ((packed));
+} __packed;
 
 #define __COMPAT_GF0_SIZE (sizeof(struct compat_group_filter) - \
 			sizeof(struct __kernel_sockaddr_storage))
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index f28ad2c..499c045 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -1463,7 +1463,7 @@ struct iucv_path_pending {
 	u32 res3;
 	u8  ippollfg;
 	u8  res4[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_path_pending(struct iucv_irq_data *data)
 {
@@ -1524,7 +1524,7 @@ struct iucv_path_complete {
 	u32 res3;
 	u8  ippollfg;
 	u8  res4[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_path_complete(struct iucv_irq_data *data)
 {
@@ -1554,7 +1554,7 @@ struct iucv_path_severed {
 	u32 res4;
 	u8  ippollfg;
 	u8  res5[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_path_severed(struct iucv_irq_data *data)
 {
@@ -1590,7 +1590,7 @@ struct iucv_path_quiesced {
 	u32 res4;
 	u8  ippollfg;
 	u8  res5[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_path_quiesced(struct iucv_irq_data *data)
 {
@@ -1618,7 +1618,7 @@ struct iucv_path_resumed {
 	u32 res4;
 	u8  ippollfg;
 	u8  res5[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_path_resumed(struct iucv_irq_data *data)
 {
@@ -1649,7 +1649,7 @@ struct iucv_message_complete {
 	u32 ipbfln2f;
 	u8  ippollfg;
 	u8  res2[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_message_complete(struct iucv_irq_data *data)
 {
@@ -1694,7 +1694,7 @@ struct iucv_message_pending {
 	u32 ipbfln2f;
 	u8  ippollfg;
 	u8  res2[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void iucv_message_pending(struct iucv_irq_data *data)
 {
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index c7000a6..a2ed0f7 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -600,7 +600,7 @@ struct iapp_layer2_update {
 	u8 ssap;		/* 0 */
 	u8 control;
 	u8 xid_info[3];
-} __attribute__ ((packed));
+} __packed;
 
 static void ieee80211_send_layer2_update(struct sta_info *sta)
 {
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 1a9e2da..ec3e5c3 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1084,7 +1084,7 @@ struct ieee80211_tx_status_rtap_hdr {
 	u8 padding_for_rate;
 	__le16 tx_flags;
 	u8 data_retries;
-} __attribute__ ((packed));
+} __packed;
 
 
 /* HT */
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 6e2a7bc..2d9a2ee 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2139,7 +2139,7 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx,
 		u8 rate_or_pad;
 		__le16 chan_freq;
 		__le16 chan_flags;
-	} __attribute__ ((packed)) *rthdr;
+	} __packed *rthdr;
 	struct sk_buff *skb = rx->skb, *skb2;
 	struct net_device *prev_dev = NULL;
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index bd2a50b..246f929 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1817,7 +1817,7 @@ malformed:
 struct __sctp_missing {
 	__be32 num_missing;
 	__be16 type;
-}  __attribute__((packed));
+}  __packed;
 
 /*
  * Report a missing mandatory parameter.


