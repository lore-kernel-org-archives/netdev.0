From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/2] sctp: reduce indent level in sctp_copy_local_addr_list
Date: Fri, 19 Aug 2016 19:30:21 +0800
Message-ID: <4d3c7b176bc8d5c48807ed60d83793c9d02e3757.1471605833.git.lucien.xin@gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34880 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbcHSNfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:35:41 -0400
In-Reply-To: <cover.1471605833.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1471605833.git.lucien.xin@gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to reduce indent level by using continue when the addr
is not allowed, and also drop end_copy by using break.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/protocol.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 7b523e3..da5d82b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -205,26 +205,27 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
 	list_for_each_entry_rcu(addr, &net->sctp.local_addr_list, list) {
 		if (!addr->valid)
 			continue;
-		if (sctp_in_scope(net, &addr->a, scope)) {
-			/* Now that the address is in scope, check to see if
-			 * the address type is really supported by the local
-			 * sock as well as the remote peer.
-			 */
-			if ((((AF_INET == addr->a.sa.sa_family) &&
-			      (copy_flags & SCTP_ADDR4_PEERSUPP))) ||
-			    (((AF_INET6 == addr->a.sa.sa_family) &&
-			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
-			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
-				error = sctp_add_bind_addr(bp, &addr->a,
-						    sizeof(addr->a),
-						    SCTP_ADDR_SRC, GFP_ATOMIC);
-				if (error)
-					goto end_copy;
-			}
-		}
+		if (!sctp_in_scope(net, &addr->a, scope))
+			continue;
+
+		/* Now that the address is in scope, check to see if
+		 * the address type is really supported by the local
+		 * sock as well as the remote peer.
+		 */
+		if (addr->a.sa.sa_family == AF_INET &&
+		    !(copy_flags & SCTP_ADDR4_PEERSUPP))
+			continue;
+		if (addr->a.sa.sa_family == AF_INET6 &&
+		    (!(copy_flags & SCTP_ADDR6_ALLOWED) ||
+		     !(copy_flags & SCTP_ADDR6_PEERSUPP)))
+			continue;
+
+		error = sctp_add_bind_addr(bp, &addr->a, sizeof(addr->a),
+					   SCTP_ADDR_SRC, GFP_ATOMIC);
+		if (error)
+			break;
 	}
 
-end_copy:
 	rcu_read_unlock();
 	return error;
 }
-- 
2.1.0
