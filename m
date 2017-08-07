From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] netfilter: ebtables: use audit_log()
Date: Mon,  7 Aug 2017 21:44:25 +0800
Message-ID: <bcbd9b076cee1b585a756a1eadd16325dc341ca4.1502098910.git.geliangtang@gmail.com>
References: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use audit_log() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/bridge/netfilter/ebtables.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 9c6e619..54c7ef4 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1069,15 +1069,10 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 
 #ifdef CONFIG_AUDIT
 	if (audit_enabled) {
-		struct audit_buffer *ab;
-
-		ab = audit_log_start(current->audit_context, GFP_KERNEL,
-				     AUDIT_NETFILTER_CFG);
-		if (ab) {
-			audit_log_format(ab, "table=%s family=%u entries=%u",
-					 repl->name, AF_BRIDGE, repl->nentries);
-			audit_log_end(ab);
-		}
+		audit_log(current->audit_context, GFP_KERNEL,
+			  AUDIT_NETFILTER_CFG,
+			  "table=%s family=%u entries=%u",
+			  repl->name, AF_BRIDGE, repl->nentries);
 	}
 #endif
 	return ret;
-- 
2.9.3
