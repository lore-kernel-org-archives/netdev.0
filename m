From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 02/16] tipc: wakeup sleeping
	users at disconnect
Date: Thu, 27 Oct 2016 16:22:23 +0200
Message-ID: <1477578157-13256-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, in filter_connect() when we terminate a connection due to
an error message from peer, we set the socket state to DISCONNECTING.

The socket is notified about this broken connection using EPIPE when
a user tries to send a message. However if a socket was waiting on a
poll() while the connection is being terminated, we fail to wakeup
that socket.

In this commit, we wakeup sleeping sockets at connection termination.

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index adf3e6ecf61e..cd01deb1da9c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1599,6 +1599,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			/* Let timer expire on it's own */
 			tipc_node_remove_conn(net, tsk_peer_node(tsk),
 					      tsk->portid);
+			sk->sk_state_change(sk);
 		}
 		return true;
 
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
