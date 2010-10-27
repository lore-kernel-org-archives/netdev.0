From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 3/4] tipc: Update arguments to use size_t for iovec array sizes
Date: Wed, 27 Oct 2010 15:29:32 -0400
Message-ID: <1288207773-25448-4-git-send-email-paul.gortmaker@windriver.com>
References: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	torvalds@linux-foundation.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43521 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102Ab0J0Tdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:33:52 -0400
In-Reply-To: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Ensures that all routines that pass iovec arrays as arguments specify
the array length using "size_t" to avoid the risk of accidentally
truncating a large array.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
---
 include/net/tipc/tipc.h |    8 ++++----
 net/tipc/link.c         |    6 +++---
 net/tipc/link.h         |    2 +-
 net/tipc/port.c         |   16 ++++++++--------
 net/tipc/port.h         |    2 +-
 5 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/net/tipc/tipc.h b/include/net/tipc/tipc.h
index 1e0645e..7750e2b 100644
--- a/include/net/tipc/tipc.h
+++ b/include/net/tipc/tipc.h
@@ -157,18 +157,18 @@ int tipc_shutdown(u32 ref);
 
 
 int tipc_send(u32 portref,
-	      unsigned int num_sect,
+	      size_t num_sect,
 	      struct iovec const *msg_sect);
 
 int tipc_send2name(u32 portref, 
 		   struct tipc_name const *name, 
 		   u32 domain,
-		   unsigned int num_sect,
+		   size_t num_sect,
 		   struct iovec const *msg_sect);
 
 int tipc_send2port(u32 portref,
 		   struct tipc_portid const *dest,
-		   unsigned int num_sect,
+		   size_t num_sect,
 		   struct iovec const *msg_sect);
 
 int tipc_send_buf2port(u32 portref,
@@ -179,7 +179,7 @@ int tipc_send_buf2port(u32 portref,
 int tipc_multicast(u32 portref, 
 		   struct tipc_name_seq const *seq, 
 		   u32 domain,	/* currently unused */
-		   unsigned int section_count,
+		   size_t section_count,
 		   struct iovec const *msg);
 #endif
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a997d9f..a92099f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -106,7 +106,7 @@ static int  link_recv_changeover_msg(struct link **l_ptr, struct sk_buff **buf);
 static void link_set_supervision_props(struct link *l_ptr, u32 tolerance);
 static int  link_send_sections_long(struct port *sender,
 				    struct iovec const *msg_sect,
-				    u32 num_sect, u32 destnode);
+				    size_t num_sect, u32 destnode);
 static void link_check_defragm_bufs(struct link *l_ptr);
 static void link_state_event(struct link *l_ptr, u32 event);
 static void link_reset_statistics(struct link *l_ptr);
@@ -1180,7 +1180,7 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
  */
 int tipc_link_send_sections_fast(struct port *sender,
 				 struct iovec const *msg_sect,
-				 const u32 num_sect,
+				 const size_t num_sect,
 				 u32 destaddr)
 {
 	struct tipc_msg *hdr = &sender->publ.phdr;
@@ -1276,7 +1276,7 @@ exit:
  */
 static int link_send_sections_long(struct port *sender,
 				   struct iovec const *msg_sect,
-				   u32 num_sect,
+				   size_t num_sect,
 				   u32 destaddr)
 {
 	struct link *l_ptr;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index f98bc61..8832c78 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -236,7 +236,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest,u32 selector);
 int tipc_link_send_sections_fast(struct port* sender,
 				 struct iovec const *msg_sect,
-				 const u32 num_sect,
+				 const size_t num_sect,
 				 u32 destnode);
 void tipc_link_recv_bundle(struct sk_buff *buf);
 int  tipc_link_recv_fragment(struct sk_buff **pending,
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 82092ea..c65409b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -95,7 +95,7 @@ static void port_incr_out_seqno(struct port *p_ptr)
  */
 
 int tipc_multicast(u32 ref, struct tipc_name_seq const *seq, u32 domain,
-		   u32 num_sect, struct iovec const *msg_sect)
+		   size_t num_sect, struct iovec const *msg_sect)
 {
 	struct tipc_msg *hdr;
 	struct sk_buff *buf;
@@ -446,7 +446,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 }
 
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
-			      struct iovec const *msg_sect, u32 num_sect,
+			      struct iovec const *msg_sect, size_t num_sect,
 			      int err)
 {
 	struct sk_buff *buf;
@@ -1219,7 +1219,7 @@ int tipc_shutdown(u32 ref)
  *                        message for this node.
  */
 
-static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
+static int tipc_port_recv_sections(struct port *sender, size_t num_sect,
 				   struct iovec const *msg_sect)
 {
 	struct sk_buff *buf;
@@ -1236,7 +1236,7 @@ static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
  * tipc_send - send message sections on connection
  */
 
-int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
+int tipc_send(u32 ref, size_t num_sect, struct iovec const *msg_sect)
 {
 	struct port *p_ptr;
 	u32 destnode;
@@ -1277,7 +1277,7 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 static int tipc_forward2name(u32 ref,
 			     struct tipc_name const *name,
 			     u32 domain,
-			     u32 num_sect,
+			     size_t num_sect,
 			     struct iovec const *msg_sect,
 			     struct tipc_portid const *orig,
 			     unsigned int importance)
@@ -1331,7 +1331,7 @@ static int tipc_forward2name(u32 ref,
 int tipc_send2name(u32 ref,
 		   struct tipc_name const *name,
 		   unsigned int domain,
-		   unsigned int num_sect,
+		   size_t num_sect,
 		   struct iovec const *msg_sect)
 {
 	struct tipc_portid orig;
@@ -1348,7 +1348,7 @@ int tipc_send2name(u32 ref,
 
 static int tipc_forward2port(u32 ref,
 			     struct tipc_portid const *dest,
-			     unsigned int num_sect,
+			     size_t num_sect,
 			     struct iovec const *msg_sect,
 			     struct tipc_portid const *orig,
 			     unsigned int importance)
@@ -1389,7 +1389,7 @@ static int tipc_forward2port(u32 ref,
 
 int tipc_send2port(u32 ref,
 		   struct tipc_portid const *dest,
-		   unsigned int num_sect,
+		   size_t num_sect,
 		   struct iovec const *msg_sect)
 {
 	struct tipc_portid orig;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 73bbf44..baa2e71 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -110,7 +110,7 @@ extern spinlock_t tipc_port_list_lock;
 struct port_list;
 
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
-			      struct iovec const *msg_sect, u32 num_sect,
+			      struct iovec const *msg_sect, size_t num_sect,
 			      int err);
 struct sk_buff *tipc_port_get_ports(void);
 struct sk_buff *port_show_stats(const void *req_tlv_area, int req_tlv_space);
-- 
1.7.1.GIT

