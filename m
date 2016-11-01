From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 05/16] tipc: rename tsk->remote to tsk->peer for consistent naming
Date: Tue, 1 Nov 2016 14:02:38 +0100
Message-ID: <1478005369-17239-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:58796 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423512AbcKANDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:03:37 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, the peer information for connect is stored in tsk->remote
but the rest of code uses the name peer for peer/remote.

In this commit, we rename tsk->remote to tsk->peer to align with
naming convention followed in the rest of the code.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c543ae6cbf65..0546556d3517 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -65,7 +65,6 @@
  * @max_pkt: maximum packet size "hint" used when building messages sent by port
  * @portid: unique port identity in TIPC socket hash table
  * @phdr: preformatted message header used when sending messages
- * @port_list: adjacent ports in TIPC's global list of ports
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
@@ -75,7 +74,7 @@
  * @link_cong: non-zero if owner must sleep because of link congestion
  * @sent_unacked: # messages sent by socket, and not yet acked by peer
  * @rcv_unacked: # messages read by user, but not yet acked back to peer
- * @remote: 'connected' peer for dgram/rdm
+ * @peer: 'connected' peer for dgram/rdm
  * @node: hash table node
  * @rcu: rcu struct for tipc_sock
  */
@@ -101,7 +100,7 @@ struct tipc_sock {
 	u16 peer_caps;
 	u16 rcv_unacked;
 	u16 rcv_win;
-	struct sockaddr_tipc remote;
+	struct sockaddr_tipc peer;
 	struct rhash_head node;
 	struct rcu_head rcu;
 };
@@ -904,7 +903,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		return -EMSGSIZE;
 	if (unlikely(!dest)) {
 		if (tsk->connected && sock->state == SS_READY)
-			dest = &tsk->remote;
+			dest = &tsk->peer;
 		else
 			return -EDESTADDRREQ;
 	} else if (unlikely(m->msg_namelen < sizeof(*dest)) ||
@@ -1939,12 +1938,12 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	/* DGRAM/RDM connect(), just save the destaddr */
 	if (sock->state == SS_READY) {
 		if (dst->family == AF_UNSPEC) {
-			memset(&tsk->remote, 0, sizeof(struct sockaddr_tipc));
+			memset(&tsk->peer, 0, sizeof(struct sockaddr_tipc));
 			tsk->connected = 0;
 		} else if (destlen != sizeof(struct sockaddr_tipc)) {
 			res = -EINVAL;
 		} else {
-			memcpy(&tsk->remote, dest, destlen);
+			memcpy(&tsk->peer, dest, destlen);
 			tsk->connected = 1;
 		}
 		goto exit;
-- 
2.1.4
