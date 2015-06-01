From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] Revert "netfilter: ensure number of counters is >0 in do_replace()"
Date: Mon,  1 Jun 2015 19:54:02 +0200
Message-ID: <1433181242-22768-2-git-send-email-pablo@netfilter.org>
References: <1433181242-22768-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1433181242-22768-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

This partially reverts commit 1086bbe97a07 ("netfilter: ensure number of
counters is >0 in do_replace()") in net/bridge/netfilter/ebtables.c.

Setting rules with ebtables does not work any more with 1086bbe97a07 place.

There is an error message and no rules set in the end.

e.g.

~# ebtables -t nat -A POSTROUTING --src 12:34:56:78:9a:bc -j DROP
Unable to update the kernel. Two possible causes:
1. Multiple ebtables programs were executing simultaneously. The ebtables
   userspace tool doesn't by default support multiple ebtables programs
running

Reverting the ebtables part of 1086bbe97a07 makes this work again.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 24c7c96..91180a7 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1117,8 +1117,6 @@ static int do_replace(struct net *net, const void __user *user,
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
-	if (tmp.num_counters == 0)
-		return -EINVAL;
 
 	tmp.name[sizeof(tmp.name) - 1] = 0;
 
@@ -2161,8 +2159,6 @@ static int compat_copy_ebt_replace_from_user(struct ebt_replace *repl,
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
-	if (tmp.num_counters == 0)
-		return -EINVAL;
 
 	memcpy(repl, &tmp, offsetof(struct ebt_replace, hook_entry));
 
-- 
1.7.10.4

