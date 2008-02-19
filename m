From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][SCTP]: Pick up an orphaned sctp_sockets_allocated counter.
Date: Tue, 19 Feb 2008 19:36:58 +0300
Message-ID: <47BB05AA.6090101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49412 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbYBSQhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 11:37:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This counter is currently write-only.

Drawing an analogy with the similar tcp counter, I think
that this one should be pointed by the sockets_allocated
members of sctp_prot and sctpv6_prot.

Or should it be instead removed at all?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d47d578..44797ad 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6488,6 +6488,7 @@ struct proto sctp_prot = {
 	.memory_pressure = &sctp_memory_pressure,
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
+	.sockets_allocated = &sctp_sockets_allocated,
 	REF_PROTO_INUSE(sctp)
 };
 
@@ -6521,6 +6522,7 @@ struct proto sctpv6_prot = {
 	.memory_pressure = &sctp_memory_pressure,
 	.enter_memory_pressure = sctp_enter_memory_pressure,
 	.memory_allocated = &sctp_memory_allocated,
+	.sockets_allocated = &sctp_sockets_allocated,
 	REF_PROTO_INUSE(sctpv6)
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
