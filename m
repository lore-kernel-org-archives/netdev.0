From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] bridge: netfilter: using strlcpy() instead of strncpy()
Date: Fri, 17 May 2013 16:07:22 +0800
Message-ID: <5195E53A.4060406@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>
To: bart.de.schuymer@pandora.be, pablo@netfilter.org, kaber@trash.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:46350 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab3EQIIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:08:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


'name' has already set all zero when it is defined, so not need let
strncpy() to pad it again.

'name' is a string, better always let is NUL terminated, so use
strlcpy() instead of strncpy().


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/bridge/netfilter/ebtables.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 3d110c4..ac78024 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1339,7 +1339,7 @@ static inline int ebt_make_matchname(const struct ebt_entry_match *m,
 
 	/* ebtables expects 32 bytes long names but xt_match names are 29 bytes
 	   long. Copy 29 bytes and fill remaining bytes with zeroes. */
-	strncpy(name, m->u.match->name, sizeof(name));
+	strlcpy(name, m->u.match->name, sizeof(name));
 	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
@@ -1351,7 +1351,7 @@ static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
 	char __user *hlp = ubase + ((char *)w - base);
 	char name[EBT_FUNCTION_MAXNAMELEN] = {};
 
-	strncpy(name, w->u.watcher->name, sizeof(name));
+	strlcpy(name, w->u.watcher->name, sizeof(name));
 	if (copy_to_user(hlp , name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
@@ -1377,7 +1377,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
 	if (ret != 0)
 		return ret;
-	strncpy(name, t->u.target->name, sizeof(name));
+	strlcpy(name, t->u.target->name, sizeof(name));
 	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
-- 
1.7.7.6
