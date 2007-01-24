From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/tipc/: possible cleanups
Date: Wed, 24 Jan 2007 23:58:50 +0100
Message-ID: <20070124225850.GU17836@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:3430 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932856AbXAXW6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 17:58:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following possible cleanups:
- make needlessly global functions static
- #if 0 unused functions
- remove all EXPORT_SYMBOL's

My impression is that most of this might have users that are not yet 
submitted for inclusion in the kernel - one year after TIPC was merged.

If this is true, please submit the users for inclusion in the kernel.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/tipc/tipc.h      |   60 ----------------------------
 include/net/tipc/tipc_port.h |    9 ----
 net/tipc/addr.c              |    2 
 net/tipc/cluster.c           |    2 
 net/tipc/cluster.h           |    1 
 net/tipc/config.c            |    9 +++-
 net/tipc/config.h            |    7 ---
 net/tipc/core.c              |   74 ++---------------------------------
 net/tipc/core.h              |   14 ++++--
 net/tipc/dbg.c               |   15 +++++--
 net/tipc/dbg.h               |    3 -
 net/tipc/discover.c          |    4 +
 net/tipc/discover.h          |    1 
 net/tipc/link.c              |   14 +++---
 net/tipc/link.h              |    4 -
 net/tipc/name_table.c        |    3 -
 net/tipc/node.c              |    6 +-
 net/tipc/node.h              |    1 
 net/tipc/port.c              |   59 +++++++++++++++++----------
 net/tipc/port.h              |    2 
 net/tipc/subscr.c            |    2 
 net/tipc/zone.c              |    2 
 net/tipc/zone.h              |    1 
 23 files changed, 97 insertions(+), 198 deletions(-)

--- linux-2.6.20-rc4-mm1/include/net/tipc/tipc.h.old	2007-01-24 19:12:15.000000000 +0100
+++ linux-2.6.20-rc4-mm1/include/net/tipc/tipc.h	2007-01-24 20:40:58.000000000 +0100
@@ -50,8 +50,6 @@
  * TIPC operating mode routines
  */
 
-u32 tipc_get_addr(void);
-
 #define TIPC_NOT_RUNNING  0
 #define TIPC_NODE_MODE    1
 #define TIPC_NET_MODE     2
@@ -62,8 +60,6 @@
 
 void tipc_detach(unsigned int userref);
 
-int tipc_get_mode(void);
-
 /*
  * TIPC port manipulation routines
  */
@@ -153,12 +149,8 @@
 
 int tipc_shutdown(u32 ref); /* Sends SHUTDOWN msg */
 
-int tipc_isconnected(u32 portref, int *isconnected);
-
 int tipc_peer(u32 portref, struct tipc_portid *peer);
 
-int tipc_ref_valid(u32 portref); 
-
 /*
  * TIPC messaging routines
  */
@@ -170,38 +162,12 @@
 	      unsigned int num_sect,
 	      struct iovec const *msg_sect);
 
-int tipc_send_buf(u32 portref,
-		  struct sk_buff *buf,
-		  unsigned int dsz);
-
 int tipc_send2name(u32 portref, 
 		   struct tipc_name const *name, 
 		   u32 domain,	/* 0:own zone */
 		   unsigned int num_sect,
 		   struct iovec const *msg_sect);
 
-int tipc_send_buf2name(u32 portref,
-		       struct tipc_name const *name,
-		       u32 domain,
-		       struct sk_buff *buf,
-		       unsigned int dsz);
-
-int tipc_forward2name(u32 portref, 
-		      struct tipc_name const *name, 
-		      u32 domain,   /*0: own zone */
-		      unsigned int section_count,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *origin,
-		      unsigned int importance);
-
-int tipc_forward_buf2name(u32 portref,
-			  struct tipc_name const *name,
-			  u32 domain,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance);
-
 int tipc_send2port(u32 portref,
 		   struct tipc_portid const *dest,
 		   unsigned int num_sect,
@@ -212,20 +178,6 @@
 		       struct sk_buff *buf,
 		       unsigned int dsz);
 
-int tipc_forward2port(u32 portref,
-		      struct tipc_portid const *dest,
-		      unsigned int num_sect,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *origin,
-		      unsigned int importance);
-
-int tipc_forward_buf2port(u32 portref,
-			  struct tipc_portid const *dest,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance);
-
 int tipc_multicast(u32 portref, 
 		   struct tipc_name_seq const *seq, 
 		   u32 domain,	/* 0:own zone */
@@ -240,18 +192,6 @@
 		       unsigned int size);
 #endif
 
-/*
- * TIPC subscription routines
- */
-
-int tipc_ispublished(struct tipc_name const *name);
-
-/*
- * Get number of available nodes within specified domain (excluding own node)
- */
-
-unsigned int tipc_available_nodes(const u32 domain);
-
 #endif
 
 #endif
--- linux-2.6.20-rc4-mm1/net/tipc/addr.c.old	2007-01-24 19:12:34.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/addr.c	2007-01-24 19:12:50.000000000 +0100
@@ -41,10 +41,12 @@
 #include "cluster.h"
 #include "net.h"
 
+#if 0
 u32 tipc_get_addr(void)
 {
 	return tipc_own_addr;
 }
+#endif  /*  0  */
 
 /**
  * tipc_addr_domain_valid - validates a network domain address
--- linux-2.6.20-rc4-mm1/net/tipc/config.h.old	2007-01-24 19:22:06.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/config.h	2007-01-24 19:24:13.000000000 +0100
@@ -45,7 +45,6 @@
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
 int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type, 
 			void *tlv_data, int tlv_data_size);
-struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value);
 struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string);
 
 static inline struct sk_buff *tipc_cfg_reply_none(void)
@@ -53,11 +52,6 @@
 	return tipc_cfg_reply_alloc(0);
 }
 
-static inline struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
-{
-	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
-}
-
 static inline struct sk_buff *tipc_cfg_reply_error_string(char *string)
 {
 	return tipc_cfg_reply_string_type(TIPC_TLV_ERROR_STRING, string);
@@ -72,7 +66,6 @@
 				const void *req_tlv_area, int req_tlv_space, 
 				int headroom);
 
-void tipc_cfg_link_event(u32 addr, char *name, int up);
 int  tipc_cfg_init(void);
 void tipc_cfg_stop(void);
 
--- linux-2.6.20-rc4-mm1/net/tipc/config.c.old	2007-01-24 19:22:24.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/config.c	2007-01-24 19:24:08.000000000 +0100
@@ -70,10 +70,12 @@
 static int rep_headroom;		/* reply message headroom to use */
 
 
+#if 0
 void tipc_cfg_link_event(u32 addr, char *name, int up)
 {
 	/* TIPC DOESN'T HANDLE LINK EVENT SUBSCRIPTIONS AT THE MOMENT */
 }
+#endif  /*  0  */
 
 
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
@@ -104,7 +106,7 @@
 	return 1;
 }
 
-struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
+static struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
 {
 	struct sk_buff *buf;
 	__be32 value_net;
@@ -118,6 +120,11 @@
 	return buf;
 }
 
+static struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
+{
+	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
+}
+
 struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 {
 	struct sk_buff *buf;
--- linux-2.6.20-rc4-mm1/net/tipc/dbg.h.old	2007-01-24 19:29:43.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/dbg.h	2007-01-24 19:30:58.000000000 +0100
@@ -56,10 +56,7 @@
 #define TIPC_PB_MAX_STR 512	/* max printable string (with trailing NUL) */
 
 void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 size);
-void tipc_printbuf_reset(struct print_buf *pb);
-int  tipc_printbuf_empty(struct print_buf *pb);
 int  tipc_printbuf_validate(struct print_buf *pb);
-void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from);
 
 void tipc_log_reinit(int log_size);
 void tipc_log_stop(void);
--- linux-2.6.20-rc4-mm1/net/tipc/dbg.c.old	2007-01-24 19:28:38.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/dbg.c	2007-01-24 20:54:09.000000000 +0100
@@ -60,6 +60,10 @@
        *(PTR + LEN) = '\0';\
 }
 
+static void tipc_printbuf_move(struct print_buf *pb_to,
+                               struct print_buf *pb_from);
+
+
 /*
  * Locking policy when using print buffers.
  *
@@ -103,7 +107,7 @@
  * @pb: pointer to print buffer structure
  */
 
-void tipc_printbuf_reset(struct print_buf *pb)
+static void tipc_printbuf_reset(struct print_buf *pb)
 {
 	tipc_printbuf_init(pb, pb->buf, pb->size);
 }
@@ -115,7 +119,7 @@
  * Returns non-zero if print buffer is empty.
  */
 
-int tipc_printbuf_empty(struct print_buf *pb)
+static int tipc_printbuf_empty(struct print_buf *pb)
 {
 	return (!pb->buf || (pb->crs == pb->buf));
 }
@@ -164,7 +168,8 @@
  * Source print buffer becomes empty if a successful move occurs.
  */
 
-void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
+static void tipc_printbuf_move(struct print_buf *pb_to,
+			       struct print_buf *pb_from)
 {
 	int len;
 
@@ -275,6 +280,8 @@
 	return b0;
 }
 
+#if 0
+
 /**
  * print_to_console - write string of bytes to console in multiple chunks
  */
@@ -349,6 +356,8 @@
 	spin_unlock_bh(&print_lock);
 }
 
+#endif  /*  0  */
+
 /**
  * tipc_log_stop - free up TIPC log print buffer 
  */
--- linux-2.6.20-rc4-mm1/net/tipc/discover.h.old	2007-01-24 19:31:36.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/discover.h	2007-01-24 19:31:44.000000000 +0100
@@ -50,7 +50,6 @@
 
 void tipc_disc_recv_msg(struct sk_buff *buf);
 
-void tipc_disc_link_event(u32 addr, char *name, int up);
 #if 0
 int  disc_create_link(const struct tipc_link_create *argv);
 #endif
--- linux-2.6.20-rc4-mm1/net/tipc/discover.c.old	2007-01-24 19:31:50.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/discover.c	2007-01-24 19:32:07.000000000 +0100
@@ -80,6 +80,7 @@
 
 
 #if 0
+
 int disc_create_link(const struct tipc_link_create *argv) 
 {
 	/* 
@@ -87,7 +88,6 @@
 	 */
 	return TIPC_OK;
 }
-#endif
 
 /*
  * disc_lost_link(): A link has lost contact
@@ -102,6 +102,8 @@
 	 */
 }
 
+#endif  /*  0  */
+
 /** 
  * tipc_disc_init_msg - initialize a link setup message
  * @type: message type (request or response)
--- linux-2.6.20-rc4-mm1/net/tipc/link.h.old	2007-01-24 19:32:26.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/link.h	2007-01-24 19:40:46.000000000 +0100
@@ -229,7 +229,6 @@
 void tipc_link_reset_fragments(struct link *l_ptr);
 int tipc_link_is_up(struct link *l_ptr);
 int tipc_link_is_active(struct link *l_ptr);
-void tipc_link_start(struct link *l_ptr);
 u32 tipc_link_push_packet(struct link *l_ptr);
 void tipc_link_stop(struct link *l_ptr);
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space, u16 cmd);
@@ -243,9 +242,6 @@
 				 struct iovec const *msg_sect,
 				 const u32 num_sect, 
 				 u32 destnode);
-int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf);
-void tipc_link_tunnel(struct link *l_ptr, struct tipc_msg *tnl_hdr,
-		      struct tipc_msg *msg, u32 selector);
 void tipc_link_recv_bundle(struct sk_buff *buf);
 int  tipc_link_recv_fragment(struct sk_buff **pending,
 			     struct sk_buff **fb,
--- linux-2.6.20-rc4-mm1/net/tipc/link.c.old	2007-01-24 19:32:39.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/link.c	2007-01-24 19:40:55.000000000 +0100
@@ -123,6 +123,8 @@
 static void link_reset_statistics(struct link *l_ptr);
 static void link_print(struct link *l_ptr, struct print_buf *buf, 
 		       const char *str);
+static int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf);
+static void tipc_link_start(struct link *l_ptr);
 
 /*
  * Debugging code used by link routines only
@@ -514,7 +516,7 @@
 	kfree(l_ptr);
 }
 
-void tipc_link_start(struct link *l_ptr)
+static void tipc_link_start(struct link *l_ptr)
 {
 	dbg("tipc_link_start %x\n", l_ptr);
 	link_state_event(l_ptr, STARTING_EVT);
@@ -2297,10 +2299,10 @@
  * tipc_link_tunnel(): Send one message via a link belonging to 
  * another bearer. Owner node is locked.
  */
-void tipc_link_tunnel(struct link *l_ptr, 
-		      struct tipc_msg *tunnel_hdr, 
-		      struct tipc_msg  *msg,
-		      u32 selector)
+static void tipc_link_tunnel(struct link *l_ptr, 
+			     struct tipc_msg *tunnel_hdr, 
+			     struct tipc_msg  *msg,
+			     u32 selector)
 {
 	struct link *tunnel;
 	struct sk_buff *buf;
@@ -2587,7 +2589,7 @@
  * The buffer is complete, inclusive total message length. 
  * Returns user data length.
  */
-int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
+static int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 {
 	struct tipc_msg *inmsg = buf_msg(buf);
 	struct tipc_msg fragm_hdr;
--- linux-2.6.20-rc4-mm1/net/tipc/name_table.c.old	2007-01-24 20:29:44.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/name_table.c	2007-01-24 20:29:56.000000000 +0100
@@ -501,7 +501,8 @@
  * sequence overlapping with the requested sequence
  */
 
-void tipc_nameseq_subscribe(struct name_seq *nseq, struct subscription *s)
+static void tipc_nameseq_subscribe(struct name_seq *nseq,
+				   struct subscription *s)
 {
 	struct sub_seq *sseq = nseq->sseqs;
 
--- linux-2.6.20-rc4-mm1/net/tipc/node.h.old	2007-01-24 20:31:45.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/node.h	2007-01-24 20:31:50.000000000 +0100
@@ -94,7 +94,6 @@
 	} bclink;
 };
 
-extern struct node *tipc_nodes;
 extern u32 tipc_own_tag;
 
 struct node *tipc_node_create(u32 addr);
--- linux-2.6.20-rc4-mm1/net/tipc/node.c.old	2007-01-24 20:30:39.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/node.c	2007-01-24 20:31:29.000000000 +0100
@@ -50,7 +50,7 @@
 static void node_lost_contact(struct node *n_ptr);
 static void node_established_contact(struct node *n_ptr);
 
-struct node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
+static struct node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
 
 u32 tipc_own_tag = 0;
 
@@ -556,6 +556,7 @@
 }
 
 #if 0
+
 void node_print(struct print_buf *buf, struct node *n_ptr, char *str)
 {
 	u32 i;
@@ -569,7 +570,6 @@
 	tipc_printf(buf, "Active links: [%x,%x]\n",
 		    n_ptr->active_links[0], n_ptr->active_links[1]);
 }
-#endif
 
 u32 tipc_available_nodes(const u32 domain)
 {
@@ -585,6 +585,8 @@
 	return cnt;
 }
 
+#endif  /*  0  */
+
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 domain;
--- linux-2.6.20-rc4-mm1/include/net/tipc/tipc_port.h.old	2007-01-24 20:34:35.000000000 +0100
+++ linux-2.6.20-rc4-mm1/include/net/tipc/tipc_port.h	2007-01-24 20:39:50.000000000 +0100
@@ -84,13 +84,6 @@
 			void (*wakeup)(struct tipc_port *),
 			const u32 importance);
 
-/*
- * tipc_set_msg_option(): port must be locked.
- */
-int tipc_set_msg_option(struct tipc_port *tp_ptr,
-			const char *opt,
-			const u32 len);
-
 int tipc_reject_msg(struct sk_buff *buf, u32 err);
 
 int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode);
@@ -99,8 +92,6 @@
 
 struct tipc_port *tipc_get_port(const u32 ref);
 
-void *tipc_get_handle(const u32 ref);
-
 
 #endif
 
--- linux-2.6.20-rc4-mm1/net/tipc/port.h.old	2007-01-24 20:36:28.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/port.h	2007-01-24 20:36:34.000000000 +0100
@@ -113,8 +113,6 @@
 extern spinlock_t tipc_port_list_lock;
 struct port_list;
 
-int tipc_port_recv_sections(struct port *p_ptr, u32 num_sect, 
-			    struct iovec const *msg_sect);
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err);
--- linux-2.6.20-rc4-mm1/net/tipc/port.c.old	2007-01-24 20:32:22.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/port.c	2007-01-24 20:53:41.000000000 +0100
@@ -311,6 +311,7 @@
 	return (struct tipc_port *)tipc_ref_deref(ref);
 }
 
+#if 0
 /**
  * tipc_get_handle - return user handle associated to port 'ref'
  */
@@ -327,6 +328,7 @@
 	tipc_port_unlock(p_ptr);
 	return handle;
 }
+#endif  /*  0  */
 
 static int port_unreliable(struct port *p_ptr)
 {
@@ -414,12 +416,17 @@
 	return buf;
 }
 
+#if 0
+/*
+  tipc_set_msg_option(): port must be locked.
+  */
 int tipc_set_msg_option(struct tipc_port *tp_ptr, const char *opt, const u32 sz)
 {
 	msg_expand(&tp_ptr->phdr, msg_destnode(&tp_ptr->phdr));
 	msg_set_options(&tp_ptr->phdr, opt, sz);
 	return TIPC_OK;
 }
+#endif  /*  0  */
 
 int tipc_reject_msg(struct sk_buff *buf, u32 err)
 {
@@ -1301,6 +1308,7 @@
 	return tipc_disconnect(ref);
 }
 
+#if 0
 int tipc_isconnected(u32 ref, int *isconnected)
 {
 	struct port *p_ptr;
@@ -1312,6 +1320,7 @@
 	tipc_port_unlock(p_ptr);
 	return TIPC_OK;
 }
+#endif  /*  0  */
 
 int tipc_peer(u32 ref, struct tipc_portid *peer)
 {
@@ -1331,11 +1340,13 @@
 	return res;
 }
 
+#if 0
 int tipc_ref_valid(u32 ref)
 {
 	/* Works irrespective of type */
 	return !!tipc_ref_deref(ref);
 }
+#endif  /*  0  */
 
 
 /*
@@ -1343,8 +1354,8 @@
  *                        message for this node.
  */
 
-int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
-		       struct iovec const *msg_sect)
+static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
+				   struct iovec const *msg_sect)
 {
 	struct sk_buff *buf;
 	int res;
@@ -1394,6 +1405,7 @@
 	return -ELINKCONG;
 }
 
+#if 0
 /** 
  * tipc_send_buf - send message buffer on connection
  */
@@ -1442,18 +1454,19 @@
 	}
 	return -ELINKCONG;
 }
+#endif  /*  0  */
 
 /**
  * tipc_forward2name - forward message sections to port name
  */
 
-int tipc_forward2name(u32 ref, 
-		      struct tipc_name const *name, 
-		      u32 domain,
-		      u32 num_sect, 
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *orig, 
-		      unsigned int importance)
+static int tipc_forward2name(u32 ref, 
+			     struct tipc_name const *name, 
+			     u32 domain,
+			     u32 num_sect, 
+			     struct iovec const *msg_sect,
+			     struct tipc_portid const *orig, 
+			     unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1515,6 +1528,8 @@
 				 TIPC_PORT_IMPORTANCE);
 }
 
+#if 0
+
 /** 
  * tipc_forward_buf2name - forward message buffer to port name
  */
@@ -1589,16 +1604,18 @@
 				     TIPC_PORT_IMPORTANCE);
 }
 
+#endif  /*  0  */
+
 /** 
  * tipc_forward2port - forward message sections to port identity
  */
 
-int tipc_forward2port(u32 ref,
-		      struct tipc_portid const *dest,
-		      unsigned int num_sect, 
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *orig, 
-		      unsigned int importance)
+static int tipc_forward2port(u32 ref,
+			     struct tipc_portid const *dest,
+			     unsigned int num_sect, 
+			     struct iovec const *msg_sect,
+			     struct tipc_portid const *orig, 
+			     unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1650,12 +1667,12 @@
 /** 
  * tipc_forward_buf2port - forward message buffer to port identity
  */
-int tipc_forward_buf2port(u32 ref,
-			  struct tipc_portid const *dest,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance)
+static int tipc_forward_buf2port(u32 ref,
+				 struct tipc_portid const *dest,
+				 struct sk_buff *buf,
+				 unsigned int dsz,
+				 struct tipc_portid const *orig,
+				 unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
--- linux-2.6.20-rc4-mm1/net/tipc/core.h.old	2007-01-24 19:24:48.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/core.h	2007-01-24 20:50:43.000000000 +0100
@@ -69,7 +69,6 @@
 extern struct print_buf *TIPC_TEE(struct print_buf *, struct print_buf *);
 void tipc_msg_print(struct print_buf*,struct tipc_msg *,const char*);
 void tipc_printf(struct print_buf *, const char *fmt, ...);
-void tipc_dump(struct print_buf*,const char *fmt, ...);
 
 #ifdef CONFIG_TIPC_DEBUG
 
@@ -85,7 +84,6 @@
 
 #define dbg(fmt, arg...)  do {if (DBG_OUTPUT != TIPC_NULL) tipc_printf(DBG_OUTPUT, fmt, ## arg);} while(0)
 #define msg_dbg(msg, txt) do {if (DBG_OUTPUT != TIPC_NULL) tipc_msg_print(DBG_OUTPUT, msg, txt);} while(0)
-#define dump(fmt, arg...) do {if (DBG_OUTPUT != TIPC_NULL) tipc_dump(DBG_OUTPUT, fmt, ##arg);} while(0)
 
 
 /*	
@@ -176,10 +174,7 @@
  * Routines available to privileged subsystems
  */
 
-extern int  tipc_core_start(void);
-extern void tipc_core_stop(void);
 extern int  tipc_core_start_net(void);
-extern void tipc_core_stop_net(void);
 
 static inline int delimit(int val, int min, int max)
 {
@@ -334,4 +329,13 @@
 		kfree_skb(skb);
 }
 
+int tipc_handler_start(void);
+void tipc_handler_stop(void);
+int tipc_netlink_start(void);
+void tipc_netlink_stop(void);
+int tipc_socket_init(void);
+void tipc_socket_stop(void);
+int tipc_eth_media_start(void);
+void tipc_eth_media_stop(void);
+
 #endif			
--- linux-2.6.20-rc4-mm1/net/tipc/core.c.old	2007-01-24 19:13:12.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/core.c	2007-01-24 23:16:46.000000000 +0100
@@ -48,15 +48,6 @@
 #include "subscr.h"
 #include "config.h"
 
-int  tipc_eth_media_start(void);
-void tipc_eth_media_stop(void);
-int  tipc_handler_start(void);
-void tipc_handler_stop(void);
-int  tipc_socket_init(void);
-void tipc_socket_stop(void);
-int  tipc_netlink_start(void);
-void tipc_netlink_stop(void);
-
 #define TIPC_MOD_VER "1.6.2"
 
 #ifndef CONFIG_TIPC_ZONES
@@ -106,16 +97,18 @@
 int tipc_remote_management;
 
 
+#if 0
 int tipc_get_mode(void)
 {
 	return tipc_mode;
 }
+#endif  /*  0  */
 
 /**
  * tipc_core_stop_net - shut down TIPC networking sub-systems
  */
 
-void tipc_core_stop_net(void)
+static void tipc_core_stop_net(void)
 {
 	tipc_eth_media_stop();
 	tipc_net_stop();
@@ -140,7 +133,7 @@
  * tipc_core_stop - switch TIPC from SINGLE NODE to NOT RUNNING mode
  */
 
-void tipc_core_stop(void)
+static void tipc_core_stop(void)
 {
 	if (tipc_mode != TIPC_NODE_MODE)
 		return;
@@ -161,7 +154,7 @@
  * tipc_core_start - switch TIPC from NOT RUNNING to SINGLE NODE mode
  */
 
-int tipc_core_start(void)
+static int __init tipc_core_start(void)
 {
 	int res;
 
@@ -227,60 +220,3 @@
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(TIPC_MOD_VER);
 
-/* Native TIPC API for kernel-space applications (see tipc.h) */
-
-EXPORT_SYMBOL(tipc_attach);
-EXPORT_SYMBOL(tipc_detach);
-EXPORT_SYMBOL(tipc_get_addr);
-EXPORT_SYMBOL(tipc_get_mode);
-EXPORT_SYMBOL(tipc_createport);
-EXPORT_SYMBOL(tipc_deleteport);
-EXPORT_SYMBOL(tipc_ownidentity);
-EXPORT_SYMBOL(tipc_portimportance);
-EXPORT_SYMBOL(tipc_set_portimportance);
-EXPORT_SYMBOL(tipc_portunreliable);
-EXPORT_SYMBOL(tipc_set_portunreliable);
-EXPORT_SYMBOL(tipc_portunreturnable);
-EXPORT_SYMBOL(tipc_set_portunreturnable);
-EXPORT_SYMBOL(tipc_publish);
-EXPORT_SYMBOL(tipc_withdraw);
-EXPORT_SYMBOL(tipc_connect2port);
-EXPORT_SYMBOL(tipc_disconnect);
-EXPORT_SYMBOL(tipc_shutdown);
-EXPORT_SYMBOL(tipc_isconnected);
-EXPORT_SYMBOL(tipc_peer);
-EXPORT_SYMBOL(tipc_ref_valid);
-EXPORT_SYMBOL(tipc_send);
-EXPORT_SYMBOL(tipc_send_buf);
-EXPORT_SYMBOL(tipc_send2name);
-EXPORT_SYMBOL(tipc_forward2name);
-EXPORT_SYMBOL(tipc_send_buf2name);
-EXPORT_SYMBOL(tipc_forward_buf2name);
-EXPORT_SYMBOL(tipc_send2port);
-EXPORT_SYMBOL(tipc_forward2port);
-EXPORT_SYMBOL(tipc_send_buf2port);
-EXPORT_SYMBOL(tipc_forward_buf2port);
-EXPORT_SYMBOL(tipc_multicast);
-/* EXPORT_SYMBOL(tipc_multicast_buf); not available yet */
-EXPORT_SYMBOL(tipc_ispublished);
-EXPORT_SYMBOL(tipc_available_nodes);
-
-/* TIPC API for external bearers (see tipc_bearer.h) */
-
-EXPORT_SYMBOL(tipc_block_bearer);
-EXPORT_SYMBOL(tipc_continue); 
-EXPORT_SYMBOL(tipc_disable_bearer);
-EXPORT_SYMBOL(tipc_enable_bearer);
-EXPORT_SYMBOL(tipc_recv_msg);
-EXPORT_SYMBOL(tipc_register_media); 
-
-/* TIPC API for external APIs (see tipc_port.h) */
-
-EXPORT_SYMBOL(tipc_createport_raw);
-EXPORT_SYMBOL(tipc_set_msg_option);
-EXPORT_SYMBOL(tipc_reject_msg);
-EXPORT_SYMBOL(tipc_send_buf_fast);
-EXPORT_SYMBOL(tipc_acknowledge);
-EXPORT_SYMBOL(tipc_get_port);
-EXPORT_SYMBOL(tipc_get_handle);
-
--- linux-2.6.20-rc4-mm1/net/tipc/subscr.c.old	2007-01-24 20:41:12.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/subscr.c	2007-01-24 20:41:27.000000000 +0100
@@ -585,10 +585,12 @@
 }
 
 
+#if 0
 int tipc_ispublished(struct tipc_name const *name)
 {
 	u32 domain = 0;
 
 	return(tipc_nametbl_translate(name->type, name->instance,&domain) != 0);
 }
+#endif  /*  0  */
 
--- linux-2.6.20-rc4-mm1/net/tipc/zone.h.old	2007-01-24 20:41:54.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/zone.h	2007-01-24 20:41:59.000000000 +0100
@@ -61,7 +61,6 @@
 struct _zone *tipc_zone_create(u32 addr);
 void tipc_zone_delete(struct _zone *z_ptr);
 void tipc_zone_attach_cluster(struct _zone *z_ptr, struct cluster *c_ptr);
-u32 tipc_zone_next_node(u32 addr);
 
 static inline struct _zone *tipc_zone_find(u32 addr)
 {
--- linux-2.6.20-rc4-mm1/net/tipc/zone.c.old	2007-01-24 20:42:07.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/zone.c	2007-01-24 20:42:19.000000000 +0100
@@ -162,6 +162,7 @@
 }
 
 
+#if 0
 u32 tipc_zone_next_node(u32 addr)
 {
 	struct cluster *c_ptr = tipc_cltr_find(addr);
@@ -170,4 +171,5 @@
 		return tipc_cltr_next_node(c_ptr, addr);
 	return 0;
 }
+#endif  /*  0  */
 
--- linux-2.6.20-rc4-mm1/net/tipc/cluster.h.old	2007-01-24 20:59:41.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/cluster.h	2007-01-24 20:59:46.000000000 +0100
@@ -75,7 +75,6 @@
 void tipc_cltr_send_slave_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_broadcast(struct sk_buff *buf);
 int tipc_cltr_init(void);
-u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr);
 void tipc_cltr_bcast_new_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
 void tipc_cltr_send_local_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
--- linux-2.6.20-rc4-mm1/net/tipc/cluster.c.old	2007-01-24 20:59:55.000000000 +0100
+++ linux-2.6.20-rc4-mm1/net/tipc/cluster.c	2007-01-24 21:00:07.000000000 +0100
@@ -113,6 +113,7 @@
 	kfree(c_ptr);
 }
 
+#if 0
 u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr)
 {
 	struct node *n_ptr;
@@ -132,6 +133,7 @@
 	}
 	return 0;
 }
+#endif  /*  0  */
 
 void tipc_cltr_attach_node(struct cluster *c_ptr, struct node *n_ptr)
 {


