From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] tipc: remove inline instances from C source files.
Date: Mon, 23 Apr 2012 10:49:13 -0400
Message-ID: <1335192553-19054-1-git-send-email-paul.gortmaker@windriver.com>
References: <20120420.204519.1199177754002742782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35180 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344Ab2DWOtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 10:49:15 -0400
In-Reply-To: <20120420.204519.1199177754002742782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Untie gcc's hands and let it do what it wants within the
individual source files.  There are two files, node.c and
port.c -- only the latter effectively changes (gcc-4.5.2).
Objdump shows gcc deciding to not inline port_peernode().

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6a71bea..76565c9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -58,7 +58,7 @@ static atomic_t tipc_num_links = ATOMIC_INIT(0);
  * entries has been chosen so that no hash chain exceeds 8 nodes and will
  * usually be much smaller (typically only a single node).
  */
-static inline unsigned int tipc_hashfn(u32 addr)
+static unsigned int tipc_hashfn(u32 addr)
 {
 	return addr & (NODE_HTABLE_SIZE - 1);
 }
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 0f40b10..4aede40 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -59,12 +59,12 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *, u32 err);
 static void port_timeout(unsigned long ref);
 
 
-static inline u32 port_peernode(struct tipc_port *p_ptr)
+static u32 port_peernode(struct tipc_port *p_ptr)
 {
 	return msg_destnode(&p_ptr->phdr);
 }
 
-static inline u32 port_peerport(struct tipc_port *p_ptr)
+static u32 port_peerport(struct tipc_port *p_ptr)
 {
 	return msg_destport(&p_ptr->phdr);
 }
-- 
1.7.9.3
