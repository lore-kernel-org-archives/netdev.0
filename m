From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: ebtables: put module reference when an incorrect extension is found
Date: Tue, 30 Aug 2016 13:26:22 +0200
Message-ID: <1472556383-6787-7-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sabrina Dubroca <sd@queasysnail.net>

commit bcf493428840 ("netfilter: ebtables: Fix extension lookup with
identical name") added a second lookup in case the extension that was
found during the first lookup matched another extension with the same
name, but didn't release the reference on the incorrect module.

Fixes: bcf493428840 ("netfilter: ebtables: Fix extension lookup with identical name")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index cceac5b..0833c25 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -368,6 +368,8 @@ ebt_check_match(struct ebt_entry_match *m, struct xt_mtchk_param *par,
 
 	match = xt_find_match(NFPROTO_BRIDGE, m->u.name, 0);
 	if (IS_ERR(match) || match->family != NFPROTO_BRIDGE) {
+		if (!IS_ERR(match))
+			module_put(match->me);
 		request_module("ebt_%s", m->u.name);
 		match = xt_find_match(NFPROTO_BRIDGE, m->u.name, 0);
 	}
-- 
2.1.4

