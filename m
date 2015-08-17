From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: don't sanity check
	non-existing TLV (NL compat)
Date: Mon, 17 Aug 2015 14:15:10 +0200
Message-ID: <1439813710-11322-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
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

From: Richard Alpe <richard.alpe@ericsson.com>

A zero length payload means that no TLV (Type Length Value) data has
been passed. Prior to this patch a non-existing TLV could be sanity
checked with TLV_OK() resulting in random behavior where a user
sending an empty message occasionally got a incorrect "operation not
supported" message back.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/netlink_compat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 53e0fee..1eadc95 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1114,7 +1114,7 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	len = nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN);
-	if (TLV_GET_LEN(msg.req) && !TLV_OK(msg.req, len)) {
+	if (len && !TLV_OK(msg.req, len)) {
 		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_SUPPORTED);
 		err = -EOPNOTSUPP;
 		goto send;
-- 
2.1.4


------------------------------------------------------------------------------
