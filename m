From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: clarify attribute length check documentation
Date: Thu, 03 Nov 2011 11:10:05 +0100
Message-ID: <1320315005.3950.37.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:45515 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1KCKKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 06:10:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The documentation for how the length of attributes
is checked is wrong ("Exact length" isn't true, the
policy checks are for "minimum length") and a bit
misleading. Make it more complete and explain what
really happens.

Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/netlink.h |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- a/include/net/netlink.h	2011-11-03 09:26:05.000000000 +0100
+++ b/include/net/netlink.h	2011-11-03 11:01:22.000000000 +0100
@@ -192,8 +192,15 @@ enum {
  *    NLA_NUL_STRING       Maximum length of string (excluding NUL)
  *    NLA_FLAG             Unused
  *    NLA_BINARY           Maximum length of attribute payload
- *    NLA_NESTED_COMPAT    Exact length of structure payload
- *    All other            Exact length of attribute payload
+ *    NLA_NESTED           Don't use `len' field -- length verification is
+ *                         done by checking len of nested header (or empty)
+ *    NLA_NESTED_COMPAT    Minimum length of structure payload
+ *    NLA_U8, NLA_U16,
+ *    NLA_U32, NLA_U64,
+ *    NLA_MSECS            Leaving the length field zero will verify the
+ *                         given type fits, using it verifies minimum length
+ *                         just like "All other"
+ *    All other            Minimum length of attribute payload
  *
  * Example:
  * static const struct nla_policy my_policy[ATTR_MAX+1] = {
