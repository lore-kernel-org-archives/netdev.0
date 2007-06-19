From: Florian Westphal <fw-kernel@strlen.de>
Subject: [PATCH] TIPC: Fix infinite loop in netlink handler
Date: Tue, 19 Jun 2007 22:18:34 +0200
Message-ID: <20070619201834.GH4383@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, per.liden@ericsson.com,
	tipc-discussion@lists.sourceforge.net, allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The tipc netlink config handler uses the nlmsg_pid from the
request header as destination for its reply. If the application
initialized nlmsg_pid to 0, the reply is looped back to the kernel,
causing hangup. Fix: use nlmsg_pid of the skb that triggered the
request.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/tipc/netlink.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 4cdafa2..6a7f7b4 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -60,7 +60,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
+		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
 	}
 
 	return 0;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
