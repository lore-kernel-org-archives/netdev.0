From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 25/39] net: core: drop null test before destroy functions
Date: Sun, 13 Sep 2015 14:15:18 +0200
Message-ID: <1442146532-9100-26-git-send-email-Julia.Lawall@lip6.fr>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unneeded NULL test.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@ expression x; @@
-if (x != NULL) {
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
  x = NULL;
-}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/core/sock.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index ca2984a..3307c02 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2740,10 +2740,8 @@ static void req_prot_cleanup(struct request_sock_ops *rsk_prot)
 		return;
 	kfree(rsk_prot->slab_name);
 	rsk_prot->slab_name = NULL;
-	if (rsk_prot->slab) {
-		kmem_cache_destroy(rsk_prot->slab);
-		rsk_prot->slab = NULL;
-	}
+	kmem_cache_destroy(rsk_prot->slab);
+	rsk_prot->slab = NULL;
 }
 
 static int req_prot_init(const struct proto *prot)
@@ -2828,10 +2826,8 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	mutex_unlock(&proto_list_mutex);
 
-	if (prot->slab != NULL) {
-		kmem_cache_destroy(prot->slab);
-		prot->slab = NULL;
-	}
+	kmem_cache_destroy(prot->slab);
+	prot->slab = NULL;
 
 	req_prot_cleanup(prot->rsk_prot);
 
