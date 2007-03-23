From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: introduce NLA_BINARY type
Date: Fri, 23 Mar 2007 16:02:05 +0100
Message-ID: <1174662125.3366.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46909 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992448AbXCWPDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 11:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a new NLA_BINARY attribute policy type with the
verification of simply checking the maximum length of the payload.

It also fixes a small typo in the example.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: netdev@vger.kernel.org

---
 include/net/netlink.h |    4 +++-
 net/netlink/attr.c    |    5 +++++
 2 files changed, 8 insertions(+), 1 deletion(-)

--- linux-2.6.orig/include/net/netlink.h	2007-03-23 15:45:52.932598534 +0100
+++ linux-2.6/include/net/netlink.h	2007-03-23 15:46:25.962598534 +0100
@@ -171,6 +171,7 @@ enum {
 	NLA_MSECS,
 	NLA_NESTED,
 	NLA_NUL_STRING,
+	NLA_BINARY,
 	__NLA_TYPE_MAX,
 };
 
@@ -188,12 +189,13 @@ enum {
  *    NLA_STRING           Maximum length of string
  *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
  *    NLA_FLAG             Unused
+ *    NLA_BINARY           Maximum length of attribute payload
  *    All other            Exact length of attribute payload
  *
  * Example:
  * static struct nla_policy my_policy[ATTR_MAX+1] __read_mostly = {
  * 	[ATTR_FOO] = { .type = NLA_U16 },
- *	[ATTR_BAR] = { .type = NLA_STRING, len = BARSIZ },
+ *	[ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
  *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
  * };
  */
--- linux-2.6.orig/net/netlink/attr.c	2007-03-23 15:46:53.112598534 +0100
+++ linux-2.6/net/netlink/attr.c	2007-03-23 15:48:12.902598534 +0100
@@ -67,6 +67,11 @@ static int validate_nla(struct nlattr *n
 		}
 		break;
 
+	case NLA_BINARY:
+		if (pt->len && attrlen > pt->len)
+			return -ERANGE;
+		break;
+
 	default:
 		if (pt->len)
 			minlen = pt->len;


