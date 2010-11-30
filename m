From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/11] tipc: Remove unused domain argument from multicast send routine
Date: Tue, 30 Nov 2010 17:00:59 -0500
Message-ID: <1291154463-26346-8-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58723 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab0K3WBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:13 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates an unused argument from tipc_multicast(), now that this
routine can no longer be called by kernel-based applications.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c   |    2 +-
 net/tipc/port.h   |    2 +-
 net/tipc/socket.c |    1 -
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index e822117..01dcfee 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -88,7 +88,7 @@ static void port_incr_out_seqno(struct port *p_ptr)
  * tipc_multicast - send a multicast message to local and remote destinations
  */
 
-int tipc_multicast(u32 ref, struct tipc_name_seq const *seq, u32 domain,
+int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 		   u32 num_sect, struct iovec const *msg_sect)
 {
 	struct tipc_msg *hdr;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 547cd6e..711b4a0 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -235,7 +235,7 @@ int tipc_send2port(u32 portref, struct tipc_portid const *dest,
 int tipc_send_buf2port(u32 portref, struct tipc_portid const *dest,
 		struct sk_buff *buf, unsigned int dsz);
 
-int tipc_multicast(u32 portref, struct tipc_name_seq const *seq, u32 domain,
+int tipc_multicast(u32 portref, struct tipc_name_seq const *seq,
 		unsigned int section_count, struct iovec const *msg);
 
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 23a12e4..34f96ed 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -596,7 +596,6 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 				break;
 			res = tipc_multicast(tport->ref,
 					     &dest->addr.nameseq,
-					     0,
 					     m->msg_iovlen,
 					     m->msg_iov);
 		}
-- 
1.7.3.2.146.g2d444

