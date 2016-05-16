From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: check nl sock before
	parsing nested attributes
Date: Mon, 16 May 2016 11:14:54 +0200
Message-ID: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sploving1@gmail.com, tipc-discussion@lists.sourceforge.net,
	eric.dumazet@gmail.com
To: <netdev@vger.kernel.org>
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

Make sure the socket for which the user is listing publication exists
before parsing the socket netlink attributes.

Prior to this patch a call without any socket caused a NULL pointer
dereference in tipc_nl_publ_dump().

Tested-and-reported-by: Baozeng Ding <sploving1@gmail.com>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 net/tipc/socket.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1262889..3b7a799 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2853,6 +2853,9 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (err)
 			return err;
 
+		if (!attrs[TIPC_NLA_SOCK])
+			return -EINVAL;
+
 		err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX,
 				       attrs[TIPC_NLA_SOCK],
 				       tipc_nl_sock_policy);
-- 
2.1.4


------------------------------------------------------------------------------
Mobile security can be enabling, not merely restricting. Employees who
bring their own devices (BYOD) to work are irked by the imposition of MDM
restrictions. Mobile Device Manager Plus allows you to control only the
apps on BYO-devices by containerizing them, leaving personal data untouched!
https://ad.doubleclick.net/ddm/clk/304595813;131938128;j
