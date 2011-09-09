From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/10] selinux: tag avc cache alloc as non-critical
Date: Fri,  9 Sep 2011 12:00:46 +0100
Message-ID: <1315566054-17209-3-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Cc: Linux-Netdev <netdev@vger.kernel.org>,
	Linux-NFS <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mel Gorman <mgorman@suse.de>
To: Linux-MM <linux-mm@kvack.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Failing to allocate a cache entry will only harm performance not
correctness.  Do not consume valuable reserve pages for something
like that.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 security/selinux/avc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index dca1c22..a68d200 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -280,7 +280,7 @@ static struct avc_node *avc_alloc_node(void)
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
