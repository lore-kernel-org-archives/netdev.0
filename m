From: <erik.hugne@ericsson.com>
Subject: [PATCH] tipc: set sk_err correctly when
	connection fails
Date: Fri, 23 Aug 2013 15:56:40 +0200
Message-ID: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhan.tt.vo@dektech.com.au, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<paul.gortmaker@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

This fixes a problem when connect() fails and returns the error
code as a positive value, whereas errno itself is never set. The
reason is that error codes set in sk_err should never be inverted.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ce8249c..6cc7ddd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1257,7 +1257,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 		/* Accept only ACK or NACK message */
 		if (unlikely(msg_errcode(msg))) {
 			sock->state = SS_DISCONNECTING;
-			sk->sk_err = -ECONNREFUSED;
+			sk->sk_err = ECONNREFUSED;
 			retval = TIPC_OK;
 			break;
 		}
@@ -1268,7 +1268,7 @@ static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **buf)
 		res = auto_connect(sock, msg);
 		if (res) {
 			sock->state = SS_DISCONNECTING;
-			sk->sk_err = res;
+			sk->sk_err = -res;
 			retval = TIPC_OK;
 			break;
 		}
-- 
1.7.9.5


------------------------------------------------------------------------------
Introducing Performance Central, a new site from SourceForge and 
AppDynamics. Performance Central is your source for news, insights, 
analysis and resources for efficient Application Performance Management. 
Visit us today!
http://pubads.g.doubleclick.net/gampad/clk?id=48897511&iu=/4140/ostg.clktrk
