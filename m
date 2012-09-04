From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/4] slab: fix starting index for finding another object
Date: Tue,  4 Sep 2012 18:24:37 +0100
Message-ID: <1346779479-1097-3-git-send-email-mgorman@suse.de>
References: <1346779479-1097-1-git-send-email-mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Chuck Lever <chuck.lever@oracle.com>, Joonsoo Kim <js1304@gmail.com>,
	Pekka@suse.de, "Enberg <penberg"@kernel.org,
	David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1346779479-1097-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Joonsoo Kim <js1304@gmail.com>

In array cache, there is a object at index 0, check it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index d34a903..c685475 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -983,7 +983,7 @@ static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 		}
 
 		/* The caller cannot use PFMEMALLOC objects, find another one */
-		for (i = 1; i < ac->avail; i++) {
+		for (i = 0; i < ac->avail; i++) {
 			/* If a !PFMEMALLOC object is found, swap them */
 			if (!is_obj_pfmemalloc(ac->entry[i])) {
 				objp = ac->entry[i];
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
