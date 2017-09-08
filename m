From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: core: remove erroneous warn_on
Date: Fri,  8 Sep 2017 19:45:46 +0200
Message-ID: <1504892748-1605-8-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

kernel test robot reported:

WARNING: CPU: 0 PID: 1244 at net/netfilter/core.c:218 __nf_hook_entries_try_shrink+0x49/0xcd
[..]

After allowing batching in nf_unregister_net_hooks its possible that an earlier
call to __nf_hook_entries_try_shrink already compacted the list.
If this happens we don't need to do anything.

Fixes: d3ad2c17b4047 ("netfilter: core: batch nf_unregister_net_hooks synchronize_net calls")
Reported-by: kernel test robot <xiaolong.ye@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 04fe25abc5f6..52cd2901a097 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -215,7 +215,7 @@ static void *__nf_hook_entries_try_shrink(struct nf_hook_entries __rcu **pp)
 	if (skip == hook_entries)
 		goto out_assign;
 
-	if (WARN_ON(skip == 0))
+	if (skip == 0)
 		return NULL;
 
 	hook_entries -= skip;
-- 
2.1.4

