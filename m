From: pablo@netfilter.org
Subject: [PATCH 4/6] netfilter: bridge: fix wrong pointer dereference
Date: Tue,  6 Mar 2012 12:22:53 +0100
Message-ID: <1331032975-5303-5-git-send-email-pablo@netfilter.org>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

In adf7ff8, a invalid dereference was added in ebt_make_names.

CC [M]  net/bridge/netfilter/ebtables.o
net/bridge/netfilter/ebtables.c: In function `ebt_make_names':
net/bridge/netfilter/ebtables.c:1371:20: warning: `t' may be used uninitialized in this function [-Wuninitialized]

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 15e9575..5fe2ff3 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1368,7 +1368,6 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	if (e->bitmask == 0)
 		return 0;
 
-	strncpy(name, t->u.target->name, sizeof(name));
 	hlp = ubase + (((char *)e + e->target_offset) - base);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
@@ -1378,6 +1377,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
 	if (ret != 0)
 		return ret;
+	strncpy(name, t->u.target->name, sizeof(name));
 	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
-- 
1.7.7.3

