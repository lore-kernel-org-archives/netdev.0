From: pablo@netfilter.org
Subject: [PATCH] netfilter: bridge: fix module autoload in compat case
Date: Thu,  1 Mar 2012 12:02:19 +0100
Message-ID: <1330599739-1645-2-git-send-email-pablo@netfilter.org>
References: <1330599739-1645-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330599739-1645-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We expected 0 if module doesn't exist, which is no longer the case
(42046e2e45c109ba703993c510401a11f716c8df,
netfilter: x_tables: return -ENOENT for non-existant matches/targets).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5864cc4..8aa4ad0 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1893,10 +1893,7 @@ static int compat_mtw_from_user(struct compat_ebt_entry_mwt *mwt,
 
 	switch (compat_mwt) {
 	case EBT_COMPAT_MATCH:
-		match = try_then_request_module(xt_find_match(NFPROTO_BRIDGE,
-						name, 0), "ebt_%s", name);
-		if (match == NULL)
-			return -ENOENT;
+		match = xt_request_find_match(NFPROTO_BRIDGE, name, 0);
 		if (IS_ERR(match))
 			return PTR_ERR(match);
 
@@ -1915,10 +1912,7 @@ static int compat_mtw_from_user(struct compat_ebt_entry_mwt *mwt,
 		break;
 	case EBT_COMPAT_WATCHER: /* fallthrough */
 	case EBT_COMPAT_TARGET:
-		wt = try_then_request_module(xt_find_target(NFPROTO_BRIDGE,
-						name, 0), "ebt_%s", name);
-		if (wt == NULL)
-			return -ENOENT;
+		wt = xt_request_find_target(NFPROTO_BRIDGE, name, 0);
 		if (IS_ERR(wt))
 			return PTR_ERR(wt);
 		off = xt_compat_target_offset(wt);
-- 
1.7.7.3

