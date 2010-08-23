From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH net-2.6] header: fix broken headers for user space
Date: Mon, 23 Aug 2010 11:25:05 +0800
Message-ID: <1282533905-20768-1-git-send-email-xiaosuo@gmail.com>
Cc: Jes Sorensen <jes@trained-monkey.org>,
	Paul Clements <Paul.Clements@steeleye.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-hippi@sunsite.dk,
	netfilter-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65239 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab0HWDZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 23:25:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__packed is only defined in kernel space, so we should use
__attribute__((packed)) for the code shared between kernel and user space.

Two __attribute() annotations are replaced with __attribute__() too.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/if_ether.h               |    2 +-
 include/linux/if_fddi.h                |    8 ++++----
 include/linux/if_hippi.h               |    8 ++++----
 include/linux/if_pppox.h               |   10 +++++-----
 include/linux/ipv6.h                   |    4 ++--
 include/linux/nbd.h                    |    2 +-
 include/linux/ncp.h                    |   10 +++++-----
 include/linux/netfilter/xt_IDLETIMER.h |    2 +-
 include/linux/phonet.h                 |    4 ++--
 include/linux/rfkill.h                 |    2 +-
 10 files changed, 26 insertions(+), 26 deletions(-)
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index c831467..bed7a46 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -119,7 +119,7 @@ struct ethhdr {
 	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
 	unsigned char	h_source[ETH_ALEN];	/* source ether addr	*/
 	__be16		h_proto;		/* packet type ID field	*/
-} __packed;
+} __attribute__((packed));
 
 #ifdef __KERNEL__
 #include <linux/skbuff.h>
diff --git a/include/linux/if_fddi.h b/include/linux/if_fddi.h
index 9947c39..e6dc11e 100644
--- a/include/linux/if_fddi.h
+++ b/include/linux/if_fddi.h
@@ -67,7 +67,7 @@ struct fddi_8022_1_hdr {
 	__u8	dsap;					/* destination service access point */
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl;					/* control byte #1 */
-} __packed;
+} __attribute__((packed));
 
 /* Define 802.2 Type 2 header */
 struct fddi_8022_2_hdr {
@@ -75,7 +75,7 @@ struct fddi_8022_2_hdr {
 	__u8	ssap;					/* source service access point */
 	__u8	ctrl_1;					/* control byte #1 */
 	__u8	ctrl_2;					/* control byte #2 */
-} __packed;
+} __attribute__((packed));
 
 /* Define 802.2 SNAP header */
 #define FDDI_K_OUI_LEN	3
@@ -85,7 +85,7 @@ struct fddi_snap_hdr {
 	__u8	ctrl;					/* always 0x03 */
 	__u8	oui[FDDI_K_OUI_LEN];	/* organizational universal id */
 	__be16	ethertype;				/* packet type ID field */
-} __packed;
+} __attribute__((packed));
 
 /* Define FDDI LLC frame header */
 struct fddihdr {
@@ -98,7 +98,7 @@ struct fddihdr {
 		struct fddi_8022_2_hdr		llc_8022_2;
 		struct fddi_snap_hdr		llc_snap;
 		} hdr;
-} __packed;
+} __attribute__((packed));
 
 #ifdef __KERNEL__
 #include <linux/netdevice.h>
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index 5fe5f30..cdc049f 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -104,7 +104,7 @@ struct hippi_fp_hdr {
 	__be32		fixed;
 #endif
 	__be32		d2_size;
-} __packed;
+} __attribute__((packed));
 
 struct hippi_le_hdr {
 #if defined (__BIG_ENDIAN_BITFIELD)
@@ -129,7 +129,7 @@ struct hippi_le_hdr {
 	__u8		daddr[HIPPI_ALEN];
 	__u16		locally_administered;
 	__u8		saddr[HIPPI_ALEN];
-} __packed;
+} __attribute__((packed));
 
 #define HIPPI_OUI_LEN	3
 /*
@@ -142,12 +142,12 @@ struct hippi_snap_hdr {
 	__u8	ctrl;			/* always 0x03 */
 	__u8	oui[HIPPI_OUI_LEN];	/* organizational universal id (zero)*/
 	__be16	ethertype;		/* packet type ID field */
-} __packed;
+} __attribute__((packed));
 
 struct hippi_hdr {
 	struct hippi_fp_hdr	fp;
 	struct hippi_le_hdr	le;
 	struct hippi_snap_hdr	snap;
-} __packed;
+} __attribute__((packed));
 
 #endif	/* _LINUX_IF_HIPPI_H */
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 1925e0c..27741e0 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -59,7 +59,7 @@ struct sockaddr_pppox {
        union{ 
                struct pppoe_addr       pppoe; 
        }sa_addr; 
-} __packed;
+} __attribute__((packed));
 
 /* The use of the above union isn't viable because the size of this
  * struct must stay fixed over time -- applications use sizeof(struct
@@ -70,7 +70,7 @@ struct sockaddr_pppol2tp {
 	sa_family_t     sa_family;      /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tp_addr pppol2tp;
-} __packed;
+} __attribute__((packed));
 
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
@@ -79,7 +79,7 @@ struct sockaddr_pppol2tpv3 {
 	sa_family_t     sa_family;      /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpv3_addr pppol2tp;
-} __packed;
+} __attribute__((packed));
 
 /*********************************************************************
  *
@@ -101,7 +101,7 @@ struct pppoe_tag {
 	__be16 tag_type;
 	__be16 tag_len;
 	char tag_data[0];
-} __attribute ((packed));
+} __attribute__ ((packed));
 
 /* Tag identifiers */
 #define PTT_EOL		__cpu_to_be16(0x0000)
@@ -129,7 +129,7 @@ struct pppoe_hdr {
 	__be16 sid;
 	__be16 length;
 	struct pppoe_tag tag[0];
-} __packed;
+} __attribute__((packed));
 
 /* Length of entire PPPoE + PPP header */
 #define PPPOE_SES_HLEN	8
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index ab9e9e8..e62683b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -58,7 +58,7 @@ struct ipv6_opt_hdr {
 	/* 
 	 * TLV encoded option data follows.
 	 */
-} __packed;	/* required for some archs */
+} __attribute__((packed));	/* required for some archs */
 
 #define ipv6_destopt_hdr ipv6_opt_hdr
 #define ipv6_hopopt_hdr  ipv6_opt_hdr
@@ -99,7 +99,7 @@ struct ipv6_destopt_hao {
 	__u8			type;
 	__u8			length;
 	struct in6_addr		addr;
-} __packed;
+} __attribute__((packed));
 
 /*
  *	IPv6 fixed header
diff --git a/include/linux/nbd.h b/include/linux/nbd.h
index bb58854..d146ca1 100644
--- a/include/linux/nbd.h
+++ b/include/linux/nbd.h
@@ -88,7 +88,7 @@ struct nbd_request {
 	char handle[8];
 	__be64 from;
 	__be32 len;
-} __packed;
+} __attribute__((packed));
 
 /*
  * This is the reply packet that nbd-server sends back to the client after
diff --git a/include/linux/ncp.h b/include/linux/ncp.h
index 3ace837..99f0ade 100644
--- a/include/linux/ncp.h
+++ b/include/linux/ncp.h
@@ -27,7 +27,7 @@ struct ncp_request_header {
 	__u8 conn_high;
 	__u8 function;
 	__u8 data[0];
-} __packed;
+} __attribute__((packed));
 
 #define NCP_REPLY                (0x3333)
 #define NCP_WATCHDOG		 (0x3E3E)
@@ -42,7 +42,7 @@ struct ncp_reply_header {
 	__u8 completion_code;
 	__u8 connection_state;
 	__u8 data[0];
-} __packed;
+} __attribute__((packed));
 
 #define NCP_VOLNAME_LEN (16)
 #define NCP_NUMBER_OF_VOLUMES (256)
@@ -158,7 +158,7 @@ struct nw_info_struct {
 #ifdef __KERNEL__
 	struct nw_nfs_info nfs;
 #endif
-} __packed;
+} __attribute__((packed));
 
 /* modify mask - use with MODIFY_DOS_INFO structure */
 #define DM_ATTRIBUTES		  (cpu_to_le32(0x02))
@@ -190,12 +190,12 @@ struct nw_modify_dos_info {
 	__u16 inheritanceGrantMask;
 	__u16 inheritanceRevokeMask;
 	__u32 maximumSpace;
-} __packed;
+} __attribute__((packed));
 
 struct nw_search_sequence {
 	__u8 volNumber;
 	__u32 dirBase;
 	__u32 sequence;
-} __packed;
+} __attribute__((packed));
 
 #endif				/* _LINUX_NCP_H */
diff --git a/include/linux/netfilter/xt_IDLETIMER.h b/include/linux/netfilter/xt_IDLETIMER.h
index 3e1aa1b..208ae93 100644
--- a/include/linux/netfilter/xt_IDLETIMER.h
+++ b/include/linux/netfilter/xt_IDLETIMER.h
@@ -39,7 +39,7 @@ struct idletimer_tg_info {
 	char label[MAX_IDLETIMER_LABEL_SIZE];
 
 	/* for kernel module internal use only */
-	struct idletimer_tg *timer __attribute((aligned(8)));
+	struct idletimer_tg *timer __attribute__((aligned(8)));
 };
 
 #endif
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 24426c3..76edadf 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -56,7 +56,7 @@ struct phonethdr {
 	__be16	pn_length;
 	__u8	pn_robj;
 	__u8	pn_sobj;
-} __packed;
+} __attribute__((packed));
 
 /* Common Phonet payload header */
 struct phonetmsg {
@@ -98,7 +98,7 @@ struct sockaddr_pn {
 	__u8 spn_dev;
 	__u8 spn_resource;
 	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(sa_family_t) - 3];
-} __packed;
+} __attribute__((packed));
 
 /* Well known address */
 #define PN_DEV_PC	0x10
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index 4f82326..08c32e4 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -81,7 +81,7 @@ struct rfkill_event {
 	__u8  type;
 	__u8  op;
 	__u8  soft, hard;
-} __packed;
+} __attribute__((packed));
 
 /*
  * We are planning to be backward and forward compatible with changes
