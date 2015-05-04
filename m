From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 5/5] tipc: deal with return value
	of tipc_conn_new callback
Date: Mon, 4 May 2015 10:36:48 +0800
Message-ID: <1430707008-11141-6-git-send-email-ying.xue@windriver.com>
References: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Once tipc_conn_new() returns NULL, the connection should be shut
down immediately, otherwise, oops may happen due to the NULL pointer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericson.com>
---
 net/tipc/server.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 77ff03e..a91a2f7 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -309,6 +309,10 @@ static int tipc_accept_from_sock(struct tipc_conn *con)
 
 	/* Notify that new connection is incoming */
 	newcon->usr_data = s->tipc_conn_new(newcon->conid);
+	if (!newcon->usr_data) {
+		sock_release(newsock);
+		return -ENOMEM;
+	}
 
 	/* Wake up receive process in case of 'SYN+' message */
 	newsock->sk->sk_data_ready(newsock->sk);
-- 
1.7.9.5


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
