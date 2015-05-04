From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/6] mvneta: Replace
 put_page(virt_to_head_page(ptr)) w/ skb_free_frag
Date: Mon, 04 May 2015 16:14:59 -0700
Message-ID: <20150504231459.1538.21842.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net
To: linux-mm@kvack.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/marvell/mvneta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..ecce8261ce3b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1359,7 +1359,7 @@ static void *mvneta_frag_alloc(const struct mvneta_port *pp)
 static void mvneta_frag_free(const struct mvneta_port *pp, void *data)
 {
 	if (likely(pp->frag_size <= PAGE_SIZE))
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
