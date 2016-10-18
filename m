From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] conntrack: restart gc immediately if GC_MAX_EVICTS is reached
Date: Tue, 18 Oct 2016 14:37:32 +0200
Message-ID: <1476794252-12398-1-git-send-email-nicolas.dichtel@6wind.com>
References: <34d607cc-5556-89c7-673d-be8cb0a4758a@6wind.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: pablo@netfilter.org, fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <34d607cc-5556-89c7-673d-be8cb0a4758a@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the maximum evictions number is reached, do not wait 5 seconds before
the next run.

CC: Florian Westphal <fw@strlen.de>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ba6a1d421222..df2f5a3901df 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -983,7 +983,7 @@ static void gc_worker(struct work_struct *work)
 		return;
 
 	ratio = scanned ? expired_count * 100 / scanned : 0;
-	if (ratio >= 90)
+	if (ratio >= 90 || expired_count == GC_MAX_EVICTS)
 		next_run = 0;
 
 	gc_work->last_bucket = i;
-- 
2.8.1

