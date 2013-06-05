From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] bridge: netfilter: using strlcpy() instead of strncpy()
Date: Wed,  5 Jun 2013 22:40:24 +0200
Message-ID: <1370464832-4216-4-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57441 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab3FEUkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 16:40:51 -0400
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>

'name' has already set all zero when it is defined, so not need let
strncpy() to pad it again.

'name' is a string, better always let is NUL terminated, so use
strlcpy() instead of strncpy().

Signed-off-by: Chen Gang <gang.chen@asianux.com>
Acked-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

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
1.7.10.4
