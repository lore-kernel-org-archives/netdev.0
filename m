From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 1/2] tipc: add support for
	stream/seqpacket socketpairs
Date: Wed, 29 Mar 2017 11:22:16 +0200
Message-ID: <1490779337-6392-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1490779337-6392-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, Erik Hugne <erik.hugne@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1490779337-6392-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@gmail.com>

sockets A and B are connected back-to-back, similar to what
AF_UNIX does.

Signed-off-by: Erik Hugne <erik.hugne@gmail.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7130e73bd42c..1198dddf72e8 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2511,6 +2511,16 @@ static int tipc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	}
 }
 
+static int tipc_socketpair(struct socket *sock1, struct socket *sock2)
+{
+	struct tipc_sock *tsk2 = tipc_sk(sock2->sk);
+	struct tipc_sock *tsk1 = tipc_sk(sock1->sk);
+
+	tipc_sk_finish_conn(tsk1, tsk2->portid, 0);
+	tipc_sk_finish_conn(tsk2, tsk1->portid, 0);
+	return 0;
+}
+
 /* Protocol switches for the various types of TIPC sockets */
 
 static const struct proto_ops msg_ops = {
@@ -2540,7 +2550,7 @@ static const struct proto_ops packet_ops = {
 	.release	= tipc_release,
 	.bind		= tipc_bind,
 	.connect	= tipc_connect,
-	.socketpair	= sock_no_socketpair,
+	.socketpair	= tipc_socketpair,
 	.accept		= tipc_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
@@ -2561,7 +2571,7 @@ static const struct proto_ops stream_ops = {
 	.release	= tipc_release,
 	.bind		= tipc_bind,
 	.connect	= tipc_connect,
-	.socketpair	= sock_no_socketpair,
+	.socketpair	= tipc_socketpair,
 	.accept		= tipc_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
