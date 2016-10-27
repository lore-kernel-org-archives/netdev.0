From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 03/16] tipc: set kern=0 in
	sk_alloc() during tipc_accept()
Date: Thu, 27 Oct 2016 16:22:24 +0200
Message-ID: <1477578157-13256-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, tipc_accept() calls sk_alloc() with kern=1. This is
incorrect as the data socket's owner is the user application.
Thus for these accepted data sockets the network namespace
refcount is skipped.

In this commit, we fix this by setting kern=0.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index cd01deb1da9c..82aec2eb8497 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2093,7 +2093,7 @@ static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	buf = skb_peek(&sk->sk_receive_queue);
 
-	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, 1);
+	res = tipc_sk_create(sock_net(sock->sk), new_sock, 0, 0);
 	if (res)
 		goto exit;
 	security_sk_clone(sock->sk, new_sock->sk);
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
