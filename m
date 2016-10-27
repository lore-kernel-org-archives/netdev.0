From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 05/16] tipc: rename
	tsk->remote to tsk->peer for consistent naming
Date: Thu, 27 Oct 2016 16:22:26 +0200
Message-ID: <1477578157-13256-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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
index 6e3774a7c831..8bc9c32c41b5 100644
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


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
