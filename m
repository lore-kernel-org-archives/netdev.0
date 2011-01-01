From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/20] tipc: cleanup various cosmetic whitespace issues
Date: Fri, 31 Dec 2010 23:59:32 -0500
Message-ID: <1293857975-30267-18-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53344 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab1AAFAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:14 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Cleans up TIPC's source code to eliminate deviations from generally
accepted coding conventions relating to leading/trailing white space
and white space around commas, braces, cases, and sizeof.

These changes are purely cosmetic and do not alter the operation of TIPC
in any way.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc.h        |   18 ++++++------
 include/linux/tipc_config.h |   59 +++++++++++++++++++++----------------------
 net/tipc/Kconfig            |    2 +-
 net/tipc/bcast.c            |    2 +-
 net/tipc/config.c           |    3 +-
 net/tipc/discover.c         |    2 +-
 net/tipc/eth_media.c        |    5 ++-
 net/tipc/link.c             |   31 ++++++++++------------
 net/tipc/link.h             |    4 +-
 net/tipc/msg.c              |   56 ++++++++++++++++++++--------------------
 net/tipc/msg.h              |    8 +++---
 net/tipc/name_table.c       |   14 +++++-----
 net/tipc/name_table.h       |    2 +-
 net/tipc/node.c             |    2 +-
 net/tipc/port.c             |   15 +++++------
 net/tipc/port.h             |    2 +-
 net/tipc/ref.c              |    6 +---
 net/tipc/socket.c           |   24 ++++++++---------
 net/tipc/subscr.c           |    2 +-
 19 files changed, 124 insertions(+), 133 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index d10614b..1eefa3f 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -1,6 +1,6 @@
 /*
  * include/linux/tipc.h: Include file for TIPC socket interface
- * 
+ *
  * Copyright (c) 2003-2006, Ericsson AB
  * Copyright (c) 2005, Wind River Systems
  * All rights reserved.
@@ -42,7 +42,7 @@
 /*
  * TIPC addressing primitives
  */
- 
+
 struct tipc_portid {
 	__u32 ref;
 	__u32 node;
@@ -89,7 +89,7 @@ static inline unsigned int tipc_node(__u32 addr)
 #define TIPC_TOP_SRV		1	/* topology service name type */
 #define TIPC_RESERVED_TYPES	64	/* lowest user-publishable name type */
 
-/* 
+/*
  * Publication scopes when binding port names and port name sequences
  */
 
@@ -112,7 +112,7 @@ static inline unsigned int tipc_node(__u32 addr)
 #define TIPC_HIGH_IMPORTANCE		2
 #define TIPC_CRITICAL_IMPORTANCE	3
 
-/* 
+/*
  * Msg rejection/connection shutdown reasons
  */
 
@@ -127,9 +127,9 @@ static inline unsigned int tipc_node(__u32 addr)
  * TIPC topology subscription service definitions
  */
 
-#define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
-#define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */
-#define TIPC_SUB_CANCEL         0x04    /* cancel a subscription */
+#define TIPC_SUB_PORTS		0x01	/* filter for port availability */
+#define TIPC_SUB_SERVICE	0x02	/* filter for service availability */
+#define TIPC_SUB_CANCEL		0x04	/* cancel a subscription */
 #if 0
 /* The following filter options are not currently implemented */
 #define TIPC_SUB_NO_BIND_EVTS	0x04	/* filter out "publish" events */
@@ -137,12 +137,12 @@ static inline unsigned int tipc_node(__u32 addr)
 #define TIPC_SUB_SINGLE_EVT	0x10	/* expire after first event */
 #endif
 
-#define TIPC_WAIT_FOREVER	~0	/* timeout for permanent subscription */
+#define TIPC_WAIT_FOREVER	(~0)	/* timeout for permanent subscription */
 
 struct tipc_subscr {
 	struct tipc_name_seq seq;	/* name sequence of interest */
 	__u32 timeout;			/* subscription duration (in ms) */
-        __u32 filter;   		/* bitmask of filter options */
+	__u32 filter;			/* bitmask of filter options */
 	char usr_handle[8];		/* available for subscriber use */
 };
 
diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 677aa13..7d42460a 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -1,6 +1,6 @@
 /*
  * include/linux/tipc_config.h: Include file for TIPC configuration interface
- * 
+ *
  * Copyright (c) 2003-2006, Ericsson AB
  * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
@@ -54,19 +54,19 @@
  * which specify parameters or results for the operation.
  *
  * For many operations, the request and reply messages have a fixed number
- * of TLVs (usually zero or one); however, some reply messages may return 
+ * of TLVs (usually zero or one); however, some reply messages may return
  * a variable number of TLVs.  A failed request is denoted by the presence
  * of an "error string" TLV in the reply message instead of the TLV(s) the
  * reply should contain if the request succeeds.
  */
- 
-/* 
+
+/*
  * Public commands:
  * May be issued by any process.
- * Accepted by own node, or by remote node only if remote management enabled.                       
+ * Accepted by own node, or by remote node only if remote management enabled.
  */
- 
-#define  TIPC_CMD_NOOP   	    0x0000    /* tx none, rx none */
+
+#define  TIPC_CMD_NOOP              0x0000    /* tx none, rx none */
 #define  TIPC_CMD_GET_NODES         0x0001    /* tx net_addr, rx node_info(s) */
 #define  TIPC_CMD_GET_MEDIA_NAMES   0x0002    /* tx none, rx media_name(s) */
 #define  TIPC_CMD_GET_BEARER_NAMES  0x0003    /* tx none, rx bearer_name(s) */
@@ -83,11 +83,11 @@
 #define  TIPC_CMD_GET_LINK_PEER     0x000D    /* tx link_name, rx ? */
 #endif
 
-/* 
+/*
  * Protected commands:
  * May only be issued by "network administration capable" process.
  * Accepted by own node, or by remote node only if remote management enabled
- * and this node is zone manager.                       
+ * and this node is zone manager.
  */
 
 #define  TIPC_CMD_GET_REMOTE_MNG    0x4003    /* tx none, rx unsigned */
@@ -116,10 +116,10 @@
 #define  TIPC_CMD_UNBLOCK_LINK      0x4106    /* tx link_name, rx none */
 #endif
 
-/* 
+/*
  * Private commands:
  * May only be issued by "network administration capable" process.
- * Accepted by own node only; cannot be used on a remote node.                       
+ * Accepted by own node only; cannot be used on a remote node.
  */
 
 #define  TIPC_CMD_SET_NODE_ADDR     0x8001    /* tx net_addr, rx none */
@@ -156,20 +156,20 @@
 #define TIPC_TLV_ULTRA_STRING	5	/* char[32768] (max) */
 
 #define TIPC_TLV_ERROR_STRING	16	/* char[128] containing "error code" */
-#define TIPC_TLV_NET_ADDR   	17	/* 32-bit integer denoting <Z.C.N> */
+#define TIPC_TLV_NET_ADDR	17	/* 32-bit integer denoting <Z.C.N> */
 #define TIPC_TLV_MEDIA_NAME	18	/* char[TIPC_MAX_MEDIA_NAME] */
 #define TIPC_TLV_BEARER_NAME	19	/* char[TIPC_MAX_BEARER_NAME] */
 #define TIPC_TLV_LINK_NAME	20	/* char[TIPC_MAX_LINK_NAME] */
 #define TIPC_TLV_NODE_INFO	21	/* struct tipc_node_info */
 #define TIPC_TLV_LINK_INFO	22	/* struct tipc_link_info */
-#define TIPC_TLV_BEARER_CONFIG  23	/* struct tipc_bearer_config */
-#define TIPC_TLV_LINK_CONFIG    24	/* struct tipc_link_config */
+#define TIPC_TLV_BEARER_CONFIG	23	/* struct tipc_bearer_config */
+#define TIPC_TLV_LINK_CONFIG	24	/* struct tipc_link_config */
 #define TIPC_TLV_NAME_TBL_QUERY	25	/* struct tipc_name_table_query */
-#define TIPC_TLV_PORT_REF   	26	/* 32-bit port reference */
+#define TIPC_TLV_PORT_REF	26	/* 32-bit port reference */
 
 /*
  * Maximum sizes of TIPC bearer-related names (including terminating NUL)
- */ 
+ */
 
 #define TIPC_MAX_MEDIA_NAME	16	/* format = media */
 #define TIPC_MAX_IF_NAME	16	/* format = interface */
@@ -234,7 +234,7 @@ struct tipc_name_table_query {
 };
 
 /*
- * The error string TLV is a null-terminated string describing the cause 
+ * The error string TLV is a null-terminated string describing the cause
  * of the request failure.  To simplify error processing (and to save space)
  * the first character of the string can be a special error code character
  * (lying by the range 0x80 to 0xFF) which represents a pre-defined reason.
@@ -258,7 +258,7 @@ struct tipc_link_create {
 
 /*
  * A TLV consists of a descriptor, followed by the TLV value.
- * TLV descriptor fields are stored in network byte order; 
+ * TLV descriptor fields are stored in network byte order;
  * TLV values must also be stored in network byte order (where applicable).
  * TLV descriptors must be aligned to addresses which are multiple of 4,
  * so up to 3 bytes of padding may exist at the end of the TLV value area.
@@ -294,7 +294,7 @@ static inline int TLV_OK(const void *tlv, __u16 space)
 
 static inline int TLV_CHECK(const void *tlv, __u16 space, __u16 exp_type)
 {
-	return TLV_OK(tlv, space) && 
+	return TLV_OK(tlv, space) &&
 		(ntohs(((struct tlv_desc *)tlv)->tlv_type) == exp_type);
 }
 
@@ -313,7 +313,7 @@ static inline int TLV_SET(void *tlv, __u16 type, void *data, __u16 len)
 }
 
 /*
- * A TLV list descriptor simplifies processing of messages 
+ * A TLV list descriptor simplifies processing of messages
  * containing multiple TLVs.
  */
 
@@ -322,15 +322,15 @@ struct tlv_list_desc {
 	__u32 tlv_space;		/* # bytes from curr TLV to list end */
 };
 
-static inline void TLV_LIST_INIT(struct tlv_list_desc *list, 
+static inline void TLV_LIST_INIT(struct tlv_list_desc *list,
 				 void *data, __u32 space)
 {
 	list->tlv_ptr = (struct tlv_desc *)data;
 	list->tlv_space = space;
 }
-	     
+
 static inline int TLV_LIST_EMPTY(struct tlv_list_desc *list)
-{ 
+{
 	return (list->tlv_space == 0);
 }
 
@@ -348,7 +348,7 @@ static inline void TLV_LIST_STEP(struct tlv_list_desc *list)
 {
 	__u16 tlv_space = TLV_ALIGN(ntohs(list->tlv_ptr->tlv_len));
 
-        list->tlv_ptr = (struct tlv_desc *)((char *)list->tlv_ptr + tlv_space);
+	list->tlv_ptr = (struct tlv_desc *)((char *)list->tlv_ptr + tlv_space);
 	list->tlv_space -= tlv_space;
 }
 
@@ -372,15 +372,14 @@ struct tipc_genlmsghdr {
 #define TIPC_GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct tipc_genlmsghdr))
 
 /*
- * Configuration messages exchanged via TIPC sockets use the TIPC configuration 
- * message header, which is defined below.  This structure is analogous 
- * to the Netlink message header, but fields are stored in network byte order 
- * and no padding is permitted between the header and the message data 
+ * Configuration messages exchanged via TIPC sockets use the TIPC configuration
+ * message header, which is defined below.  This structure is analogous
+ * to the Netlink message header, but fields are stored in network byte order
+ * and no padding is permitted between the header and the message data
  * that follows.
  */
 
-struct tipc_cfg_msg_hdr
-{
+struct tipc_cfg_msg_hdr {
 	__be32 tcm_len;		/* Message length (including header) */
 	__be16 tcm_type;	/* Command type */
 	__be16 tcm_flags;	/* Additional flags */
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 0e7ce30..0436927 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -50,7 +50,7 @@ config TIPC_PORTS
 	  Specifies how many ports can be supported by a node.
 	  Can range from 127 to 65535 ports; default is 8191.
 
-	  Setting this to a smaller value saves some memory, 
+	  Setting this to a smaller value saves some memory,
 	  setting it to higher allows for more ports.
 
 config TIPC_LOG
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index c0f3b09..9de3256 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -428,7 +428,7 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	static int rx_count = 0;
 #endif
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_node* node = tipc_node_find(msg_prevnode(msg));
+	struct tipc_node *node = tipc_node_find(msg_prevnode(msg));
 	u32 next_in;
 	u32 seqno;
 	struct sk_buff *deferred;
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 6c67132..e16750d 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -322,8 +322,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	} else if (!tipc_remote_management) {
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NO_REMOTE);
 		goto exit;
-	}
-	else if (cmd >= 0x4000) {
+	} else if (cmd >= 0x4000) {
 		u32 domain = 0;
 
 		if ((tipc_nametbl_translate(TIPC_ZM_SRV, 0, &domain) == 0) ||
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index be28f5a..fa026bd 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -130,7 +130,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 	u32 net_id = msg_bc_netid(msg);
 	u32 type = msg_type(msg);
 
-	msg_get_media_addr(msg,&media_addr);
+	msg_get_media_addr(msg, &media_addr);
 	buf_discard(buf);
 
 	if (net_id != tipc_net_id)
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 101d9cb..5dfe663 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -144,7 +144,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 
 	/* Find device with specified name */
 
-	for_each_netdev(&init_net, pdev){
+	for_each_netdev(&init_net, pdev) {
 		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
 			dev = pdev;
 			break;
@@ -155,7 +155,8 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 
 	/* Find Ethernet bearer for device (or create one) */
 
-	for (;(eb_ptr != stop) && eb_ptr->dev && (eb_ptr->dev != dev); eb_ptr++);
+	while ((eb_ptr != stop) && eb_ptr->dev && (eb_ptr->dev != dev))
+		eb_ptr++;
 	if (eb_ptr == stop)
 		return -EDQUOT;
 	if (!eb_ptr->dev) {
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 647f2ec..ef203a1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -977,8 +977,7 @@ static int link_send_buf_fast(struct link *l_ptr, struct sk_buff *buf,
 				l_ptr->next_out = buf;
 				return res;
 			}
-		}
-		else
+		} else
 			*used_max_pkt = l_ptr->max_pkt;
 	}
 	return tipc_link_send_buf(l_ptr, buf);  /* All other cases */
@@ -1132,10 +1131,10 @@ static int link_send_sections_long(struct port *sender,
 	struct tipc_node *node;
 	struct tipc_msg *hdr = &sender->publ.phdr;
 	u32 dsz = msg_data_sz(hdr);
-	u32 max_pkt,fragm_sz,rest;
+	u32 max_pkt, fragm_sz, rest;
 	struct tipc_msg fragm_hdr;
-	struct sk_buff *buf,*buf_chain,*prev;
-	u32 fragm_crs,fragm_rest,hsz,sect_rest;
+	struct sk_buff *buf, *buf_chain, *prev;
+	u32 fragm_crs, fragm_rest, hsz, sect_rest;
 	const unchar *sect_crs;
 	int curr_sect;
 	u32 fragm_no;
@@ -1212,7 +1211,7 @@ error:
 			/* Initiate new fragment: */
 			if (rest <= fragm_sz) {
 				fragm_sz = rest;
-				msg_set_type(&fragm_hdr,LAST_FRAGMENT);
+				msg_set_type(&fragm_hdr, LAST_FRAGMENT);
 			} else {
 				msg_set_type(&fragm_hdr, FRAGMENT);
 			}
@@ -1229,8 +1228,7 @@ error:
 			fragm_crs = INT_H_SIZE;
 			fragm_rest = fragm_sz;
 		}
-	}
-	while (rest > 0);
+	} while (rest > 0);
 
 	/*
 	 * Now we have a buffer chain. Select a link and check
@@ -1333,7 +1331,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 	buf = l_ptr->proto_msg_queue;
 	if (buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
-		msg_set_bcast_ack(buf_msg(buf),l_ptr->owner->bclink.last_in);
+		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
 			l_ptr->unacked_window = 0;
 			buf_discard(buf);
@@ -1847,8 +1845,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
 		}
 		prev = crs;
 		crs = crs->next;
-	}
-	while (crs);
+	} while (crs);
 
 	/* Message is a duplicate of an existing message */
 
@@ -2215,11 +2212,11 @@ void tipc_link_changeover(struct link *l_ptr)
 
 		if ((msg_user(msg) == MSG_BUNDLER) && split_bundles) {
 			struct tipc_msg *m = msg_get_wrapped(msg);
-			unchar* pos = (unchar*)m;
+			unchar *pos = (unchar *)m;
 
 			msgcount = msg_msgcnt(msg);
 			while (msgcount--) {
-				msg_set_seqno(m,msg_seqno(msg));
+				msg_set_seqno(m, msg_seqno(msg));
 				tipc_link_tunnel(l_ptr, &tunnel_hdr, m,
 						 msg_link_selector(m));
 				pos += align(msg_size(m));
@@ -2321,7 +2318,7 @@ static int link_recv_changeover_msg(struct link **l_ptr,
 	if (msg_typ == DUPLICATE_MSG) {
 		if (less(msg_seqno(msg), mod(dest_link->next_in_no)))
 			goto exit;
-		*buf = buf_extract(tunnel_buf,INT_H_SIZE);
+		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
 		if (*buf == NULL) {
 			warn("Link changeover error, duplicate msg dropped\n");
 			goto exit;
@@ -2552,8 +2549,8 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			/*  Prepare buffer for subsequent fragments. */
 
 			set_long_msg_seqno(pbuf, long_msg_seq_no);
-			set_fragm_size(pbuf,fragm_sz);
-			set_expected_frags(pbuf,exp_fragm_cnt - 1);
+			set_fragm_size(pbuf, fragm_sz);
+			set_expected_frags(pbuf, exp_fragm_cnt - 1);
 		} else {
 			warn("Link unable to reassemble fragmented message\n");
 		}
@@ -2580,7 +2577,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			*m = buf_msg(pbuf);
 			return 1;
 		}
-		set_expected_frags(pbuf,exp_frags);
+		set_expected_frags(pbuf, exp_frags);
 		return 0;
 	}
 	buf_discard(fbuf);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index eca19c2..70967e6 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -229,8 +229,8 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 void tipc_link_reset(struct link *l_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf);
-u32 tipc_link_get_max_pkt(u32 dest,u32 selector);
-int tipc_link_send_sections_fast(struct port* sender,
+u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
+int tipc_link_send_sections_fast(struct port *sender,
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
 				 u32 destnode);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 2571ffb..e81d43a 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -91,7 +91,7 @@ int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
 
 int tipc_msg_build(struct tipc_msg *hdr,
 			    struct iovec const *msg_sect, u32 num_sect,
-			    int max_size, int usrmem, struct sk_buff** buf)
+			    int max_size, int usrmem, struct sk_buff **buf)
 {
 	int dsz, sz, hsz, pos, res, cnt;
 
@@ -161,10 +161,10 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "LAST:");
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN:%x", msg_type(msg));
 
 		}
-		tipc_printf(buf, "NO(%u/%u):",msg_long_msgno(msg),
+		tipc_printf(buf, "NO(%u/%u):", msg_long_msgno(msg),
 			    msg_fragm_no(msg));
 		break;
 	case TIPC_LOW_IMPORTANCE:
@@ -190,7 +190,7 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "DIR:");
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE %u",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE %u", msg_type(msg));
 		}
 		if (msg_routed(msg) && !msg_non_seq(msg))
 			tipc_printf(buf, "ROUT:");
@@ -208,7 +208,7 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "WDRW:");
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN:%x", msg_type(msg));
 		}
 		if (msg_routed(msg))
 			tipc_printf(buf, "ROUT:");
@@ -227,39 +227,39 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			break;
 		case CONN_ACK:
 			tipc_printf(buf, "CONN_ACK:");
-			tipc_printf(buf, "ACK(%u):",msg_msgcnt(msg));
+			tipc_printf(buf, "ACK(%u):", msg_msgcnt(msg));
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
 		if (msg_routed(msg))
 			tipc_printf(buf, "ROUT:");
 		if (msg_reroute_cnt(msg))
-			tipc_printf(buf, "REROUTED(%u):",msg_reroute_cnt(msg));
+			tipc_printf(buf, "REROUTED(%u):", msg_reroute_cnt(msg));
 		break;
 	case LINK_PROTOCOL:
-		tipc_printf(buf, "PROT:TIM(%u):",msg_timestamp(msg));
+		tipc_printf(buf, "PROT:TIM(%u):", msg_timestamp(msg));
 		switch (msg_type(msg)) {
 		case STATE_MSG:
 			tipc_printf(buf, "STATE:");
-			tipc_printf(buf, "%s:",msg_probe(msg) ? "PRB" :"");
-			tipc_printf(buf, "NXS(%u):",msg_next_sent(msg));
-			tipc_printf(buf, "GAP(%u):",msg_seq_gap(msg));
-			tipc_printf(buf, "LSTBC(%u):",msg_last_bcast(msg));
+			tipc_printf(buf, "%s:", msg_probe(msg) ? "PRB" : "");
+			tipc_printf(buf, "NXS(%u):", msg_next_sent(msg));
+			tipc_printf(buf, "GAP(%u):", msg_seq_gap(msg));
+			tipc_printf(buf, "LSTBC(%u):", msg_last_bcast(msg));
 			break;
 		case RESET_MSG:
 			tipc_printf(buf, "RESET:");
 			if (msg_size(msg) != msg_hdr_sz(msg))
-				tipc_printf(buf, "BEAR:%s:",msg_data(msg));
+				tipc_printf(buf, "BEAR:%s:", msg_data(msg));
 			break;
 		case ACTIVATE_MSG:
 			tipc_printf(buf, "ACTIVATE:");
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
-		tipc_printf(buf, "PLANE(%c):",msg_net_plane(msg));
-		tipc_printf(buf, "SESS(%u):",msg_session(msg));
+		tipc_printf(buf, "PLANE(%c):", msg_net_plane(msg));
+		tipc_printf(buf, "SESS(%u):", msg_session(msg));
 		break;
 	case CHANGEOVER_PROTOCOL:
 		tipc_printf(buf, "TUNL:");
@@ -269,10 +269,10 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			break;
 		case ORIGINAL_MSG:
 			tipc_printf(buf, "ORIG:");
-			tipc_printf(buf, "EXP(%u)",msg_msgcnt(msg));
+			tipc_printf(buf, "EXP(%u)", msg_msgcnt(msg));
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
 		break;
 	case ROUTE_DISTRIBUTOR:
@@ -280,26 +280,26 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 		switch (msg_type(msg)) {
 		case EXT_ROUTING_TABLE:
 			tipc_printf(buf, "EXT_TBL:");
-			tipc_printf(buf, "TO:%x:",msg_remote_node(msg));
+			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
 			break;
 		case LOCAL_ROUTING_TABLE:
 			tipc_printf(buf, "LOCAL_TBL:");
-			tipc_printf(buf, "TO:%x:",msg_remote_node(msg));
+			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
 			break;
 		case SLAVE_ROUTING_TABLE:
 			tipc_printf(buf, "DP_TBL:");
-			tipc_printf(buf, "TO:%x:",msg_remote_node(msg));
+			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
 			break;
 		case ROUTE_ADDITION:
 			tipc_printf(buf, "ADD:");
-			tipc_printf(buf, "TO:%x:",msg_remote_node(msg));
+			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
 			break;
 		case ROUTE_REMOVAL:
 			tipc_printf(buf, "REMOVE:");
-			tipc_printf(buf, "TO:%x:",msg_remote_node(msg));
+			tipc_printf(buf, "TO:%x:", msg_remote_node(msg));
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE:%x", msg_type(msg));
 		}
 		break;
 	case LINK_CONFIG:
@@ -312,7 +312,7 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 			tipc_printf(buf, "DSC_RESP:");
 			break;
 		default:
-			tipc_printf(buf, "UNKNOWN TYPE:%x:",msg_type(msg));
+			tipc_printf(buf, "UNKNOWN TYPE:%x:", msg_type(msg));
 			break;
 		}
 		break;
@@ -393,8 +393,8 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 	}
 
 	if (msg_user(msg) ==  LINK_CONFIG) {
-		u32* raw = (u32*)msg;
-		struct tipc_media_addr* orig = (struct tipc_media_addr*)&raw[5];
+		u32 *raw = (u32 *)msg;
+		struct tipc_media_addr *orig = (struct tipc_media_addr *)&raw[5];
 		tipc_printf(buf, ":REQL(%u):", msg_req_links(msg));
 		tipc_printf(buf, ":DDOM(%x):", msg_dest_domain(msg));
 		tipc_printf(buf, ":NETID(%u):", msg_bc_netid(msg));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 68b65ef..92c4c4f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -174,7 +174,7 @@ static inline u32 msg_hdr_sz(struct tipc_msg *m)
 	return msg_bits(m, 0, 21, 0xf) << 2;
 }
 
-static inline void msg_set_hdr_sz(struct tipc_msg *m,u32 n)
+static inline void msg_set_hdr_sz(struct tipc_msg *m, u32 n)
 {
 	msg_set_bits(m, 0, 21, 0xf, n>>2);
 }
@@ -425,7 +425,7 @@ static inline u32 msg_routed(struct tipc_msg *m)
 {
 	if (likely(msg_short(m)))
 		return 0;
-	return(msg_destnode(m) ^ msg_orignode(m)) >> 11;
+	return (msg_destnode(m) ^ msg_orignode(m)) >> 11;
 }
 
 static inline u32 msg_nametype(struct tipc_msg *m)
@@ -863,7 +863,7 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect);
 int tipc_msg_build(struct tipc_msg *hdr,
 			    struct iovec const *msg_sect, u32 num_sect,
-			    int max_size, int usrmem, struct sk_buff** buf);
+			    int max_size, int usrmem, struct sk_buff **buf);
 
 static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
 {
@@ -872,7 +872,7 @@ static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr
 
 static inline void msg_get_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
 {
-	memcpy(a, &((int*)m)[5], sizeof(*a));
+	memcpy(a, &((int *)m)[5], sizeof(*a));
 }
 
 #endif
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ddc2ad4..46b2f31 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -296,8 +296,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 
 		sseq = &nseq->sseqs[inspos];
 		freesseq = &nseq->sseqs[nseq->first_free];
-		memmove(sseq + 1, sseq, (freesseq - sseq) * sizeof (*sseq));
-		memset(sseq, 0, sizeof (*sseq));
+		memmove(sseq + 1, sseq, (freesseq - sseq) * sizeof(*sseq));
+		memset(sseq, 0, sizeof(*sseq));
 		nseq->first_free++;
 		sseq->lower = lower;
 		sseq->upper = upper;
@@ -471,7 +471,7 @@ end_node:
 
 	if (!sseq->zone_list) {
 		free = &nseq->sseqs[nseq->first_free--];
-		memmove(sseq, sseq + 1, (free - (sseq + 1)) * sizeof (*sseq));
+		memmove(sseq, sseq + 1, (free - (sseq + 1)) * sizeof(*sseq));
 		removed_subseq = 1;
 	}
 
@@ -507,7 +507,7 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s
 
 	while (sseq != &nseq->sseqs[nseq->first_free]) {
 		struct publication *zl = sseq->zone_list;
-		if (zl && tipc_subscr_overlap(s,sseq->lower,sseq->upper)) {
+		if (zl && tipc_subscr_overlap(s, sseq->lower, sseq->upper)) {
 			struct publication *crs = zl;
 			int must_report = 1;
 
@@ -798,7 +798,7 @@ void tipc_nametbl_subscribe(struct subscription *s)
 	if (!seq) {
 		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
 	}
-	if (seq){
+	if (seq) {
 		spin_lock_bh(&seq->lock);
 		tipc_nameseq_subscribe(seq, s);
 		spin_unlock_bh(&seq->lock);
@@ -819,7 +819,7 @@ void tipc_nametbl_unsubscribe(struct subscription *s)
 
 	write_lock_bh(&tipc_nametbl_lock);
 	seq = nametbl_find_seq(s->seq.type);
-	if (seq != NULL){
+	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
 		spin_unlock_bh(&seq->lock);
@@ -852,7 +852,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 	}
 
 	do {
-		sprintf (portIdStr, "<%u.%u.%u:%u>",
+		sprintf(portIdStr, "<%u.%u.%u:%u>",
 			 tipc_zone(publ->node), tipc_cluster(publ->node),
 			 tipc_node(publ->node), publ->ref);
 		tipc_printf(buf, "%-26s ", portIdStr);
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 139882d..d228bd6 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -46,7 +46,7 @@ struct port_list;
  * TIPC name types reserved for internal TIPC use (both current and planned)
  */
 
-#define TIPC_ZM_SRV 3  		/* zone master service name type */
+#define TIPC_ZM_SRV 3		/* zone master service name type */
 
 
 /**
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 126d774..2ed162f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -334,7 +334,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	/* Clean up broadcast reception remains */
 	n_ptr->bclink.gap_after = n_ptr->bclink.gap_to = 0;
 	while (n_ptr->bclink.deferred_head) {
-		struct sk_buff* buf = n_ptr->bclink.deferred_head;
+		struct sk_buff *buf = n_ptr->bclink.deferred_head;
 		n_ptr->bclink.deferred_head = buf->next;
 		buf_discard(buf);
 	}
diff --git a/net/tipc/port.c b/net/tipc/port.c
index db14b7e..78fcb75 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -54,8 +54,8 @@ static DEFINE_SPINLOCK(queue_lock);
 
 static LIST_HEAD(ports);
 static void port_handle_node_down(unsigned long ref);
-static struct sk_buff* port_build_self_abort_msg(struct port *,u32 err);
-static struct sk_buff* port_build_peer_abort_msg(struct port *,u32 err);
+static struct sk_buff *port_build_self_abort_msg(struct port *, u32 err);
+static struct sk_buff *port_build_peer_abort_msg(struct port *, u32 err);
 static void port_timeout(unsigned long ref);
 
 
@@ -155,7 +155,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 
 void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
 {
-	struct tipc_msg* msg;
+	struct tipc_msg *msg;
 	struct port_list dports = {0, NULL, };
 	struct port_list *item = dp;
 	int cnt = 0;
@@ -193,7 +193,7 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
 			if ((index == 0) && (cnt != 0)) {
 				item = item->next;
 			}
-			msg_set_destport(buf_msg(b),item->ports[index]);
+			msg_set_destport(buf_msg(b), item->ports[index]);
 			tipc_port_recv_msg(b);
 		}
 	}
@@ -484,7 +484,7 @@ static void port_timeout(unsigned long ref)
 static void port_handle_node_down(unsigned long ref)
 {
 	struct port *p_ptr = tipc_port_lock(ref);
-	struct sk_buff* buf = NULL;
+	struct sk_buff *buf = NULL;
 
 	if (!p_ptr)
 		return;
@@ -620,8 +620,7 @@ static void port_print(struct port *p_ptr, struct print_buf *buf, int full_id)
 			tipc_printf(buf, " via {%u,%u}",
 				    p_ptr->publ.conn_type,
 				    p_ptr->publ.conn_instance);
-	}
-	else if (p_ptr->publ.published) {
+	} else if (p_ptr->publ.published) {
 		tipc_printf(buf, " bound to");
 		list_for_each_entry(publ, &p_ptr->publications, pport_list) {
 			if (publ->lower == publ->upper)
@@ -1099,7 +1098,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	p_ptr->publ.connected = 1;
 	k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 
-	tipc_nodesub_subscribe(&p_ptr->subscription,peer->node,
+	tipc_nodesub_subscribe(&p_ptr->subscription, peer->node,
 			  (void *)(unsigned long)ref,
 			  (net_ev_handler)port_handle_node_down);
 	res = 0;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index a9c5287..8e84b98 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -258,7 +258,7 @@ static inline void tipc_port_unlock(struct port *p_ptr)
 	spin_unlock_bh(p_ptr->publ.lock);
 }
 
-static inline struct port* tipc_port_deref(u32 ref)
+static inline struct port *tipc_port_deref(u32 ref)
 {
 	return (struct port *)tipc_ref_deref(ref);
 }
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index ab8ad32..3974529 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -178,14 +178,12 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		next_plus_upper = entry->ref;
 		tipc_ref_table.first_free = next_plus_upper & index_mask;
 		ref = (next_plus_upper & ~index_mask) + index;
-	}
-	else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
+	} else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
 		index = tipc_ref_table.init_point++;
 		entry = &(tipc_ref_table.entries[index]);
 		spin_lock_init(&entry->lock);
 		ref = tipc_ref_table.start_mask + index;
-	}
-	else {
+	} else {
 		ref = 0;
 	}
 	write_unlock_bh(&ref_table_lock);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1a2eb23..e9fc5df 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -375,7 +375,7 @@ static int bind(struct socket *sock, struct sockaddr *uaddr, int uaddr_len)
  *
  * NOTE: This routine doesn't need to take the socket lock since it only
  *       accesses socket information that is unchanging (or which changes in
- * 	 a completely predictable manner).
+ *       a completely predictable manner).
  */
 
 static int get_name(struct socket *sock, struct sockaddr *uaddr,
@@ -570,14 +570,12 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 					     dest->addr.name.domain,
 					     m->msg_iovlen,
 					     m->msg_iov);
-		}
-		else if (dest->addrtype == TIPC_ADDR_ID) {
+		} else if (dest->addrtype == TIPC_ADDR_ID) {
 			res = tipc_send2port(tport->ref,
 					     &dest->addr.id,
 					     m->msg_iovlen,
 					     m->msg_iov);
-		}
-		else if (dest->addrtype == TIPC_ADDR_MCAST) {
+		} else if (dest->addrtype == TIPC_ADDR_MCAST) {
 			if (needs_conn) {
 				res = -EOPNOTSUPP;
 				break;
@@ -812,8 +810,8 @@ static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
 		addr->addrtype = TIPC_ADDR_ID;
 		addr->addr.id.ref = msg_origport(msg);
 		addr->addr.id.node = msg_orignode(msg);
-		addr->addr.name.domain = 0;   	/* could leave uninitialized */
-		addr->scope = 0;   		/* could leave uninitialized */
+		addr->addr.name.domain = 0;	/* could leave uninitialized */
+		addr->scope = 0;		/* could leave uninitialized */
 		m->msg_namelen = sizeof(struct sockaddr_tipc);
 	}
 }
@@ -1743,10 +1741,10 @@ static int getsockopt(struct socket *sock,
 		value = jiffies_to_msecs(tipc_sk(sk)->conn_timeout);
 		/* no need to set "res", since already 0 at this point */
 		break;
-	 case TIPC_NODE_RECVQ_DEPTH:
+	case TIPC_NODE_RECVQ_DEPTH:
 		value = (u32)atomic_read(&tipc_queue_size);
 		break;
-	 case TIPC_SOCK_RECVQ_DEPTH:
+	case TIPC_SOCK_RECVQ_DEPTH:
 		value = skb_queue_len(&sk->sk_receive_queue);
 		break;
 	default:
@@ -1772,7 +1770,7 @@ static int getsockopt(struct socket *sock,
  */
 
 static const struct proto_ops msg_ops = {
-	.owner 		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
 	.bind		= bind,
@@ -1793,7 +1791,7 @@ static const struct proto_ops msg_ops = {
 };
 
 static const struct proto_ops packet_ops = {
-	.owner 		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
 	.bind		= bind,
@@ -1814,7 +1812,7 @@ static const struct proto_ops packet_ops = {
 };
 
 static const struct proto_ops stream_ops = {
-	.owner 		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.release	= release,
 	.bind		= bind,
@@ -1835,7 +1833,7 @@ static const struct proto_ops stream_ops = {
 };
 
 static const struct net_proto_family tipc_family_ops = {
-	.owner 		= THIS_MODULE,
+	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
 	.create		= tipc_create
 };
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 5102711..acc30e1 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -538,7 +538,7 @@ int tipc_subscr_start(void)
 	struct tipc_name_seq seq = {TIPC_TOP_SRV, TIPC_TOP_SRV, TIPC_TOP_SRV};
 	int res;
 
-	memset(&topsrv, 0, sizeof (topsrv));
+	memset(&topsrv, 0, sizeof(topsrv));
 	spin_lock_init(&topsrv.lock);
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
-- 
1.7.3.3

