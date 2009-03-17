From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tipc: fix non-const printf format arguments
Date: Tue, 17 Mar 2009 11:28:32 -0700
Message-ID: <20090317112832.66832ce4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, per.linden@ericsson.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54963 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465AbZCQS2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 14:28:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warnings from current gcc about using non-const strings as printf args
in TIPC. Compile tested only (not a TIPC user).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/tipc/bcast.c |    4 ++--
 net/tipc/bcast.h |    2 +-
 net/tipc/dbg.c   |    2 +-
 net/tipc/node.c  |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

--- a/net/tipc/bcast.c	2009-03-17 11:17:23.196668013 -0700
+++ b/net/tipc/bcast.c	2009-03-17 11:24:54.277355254 -0700
@@ -119,7 +119,7 @@ static struct bclink *bclink = NULL;
 static struct link *bcl = NULL;
 static DEFINE_SPINLOCK(bc_lock);
 
-char tipc_bclink_name[] = "multicast-link";
+const char tipc_bclink_name[] = "multicast-link";
 
 
 static u32 buf_seqno(struct sk_buff *buf)
@@ -800,7 +800,7 @@ int tipc_bclink_init(void)
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->b_ptr = &bcbearer->bearer;
 	bcl->state = WORKING_WORKING;
-	sprintf(bcl->name, tipc_bclink_name);
+	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 
 	if (BCLINK_LOG_BUF_SIZE) {
 		char *pb = kmalloc(BCLINK_LOG_BUF_SIZE, GFP_ATOMIC);
--- a/net/tipc/bcast.h	2009-03-17 11:19:59.985355078 -0700
+++ b/net/tipc/bcast.h	2009-03-17 11:20:07.009542787 -0700
@@ -70,7 +70,7 @@ struct port_list {
 
 struct tipc_node;
 
-extern char tipc_bclink_name[];
+extern const char tipc_bclink_name[];
 
 
 /**
--- a/net/tipc/dbg.c	2009-03-17 11:22:58.825479925 -0700
+++ b/net/tipc/dbg.c	2009-03-17 11:23:52.503463479 -0700
@@ -258,7 +258,7 @@ void tipc_printf(struct print_buf *pb, c
 	}
 
 	if (pb->echo)
-		printk(print_string);
+		printk("%s", print_string);
 
 	spin_unlock_bh(&print_lock);
 }
--- a/net/tipc/node.c	2009-03-17 11:22:24.129480376 -0700
+++ b/net/tipc/node.c	2009-03-17 11:25:13.389229628 -0700
@@ -703,7 +703,7 @@ struct sk_buff *tipc_node_get_links(cons
 
 	link_info.dest = htonl(tipc_own_addr & 0xfffff00);
 	link_info.up = htonl(1);
-	sprintf(link_info.str, tipc_bclink_name);
+	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
 
 	/* Add TLVs for any other links in scope */
