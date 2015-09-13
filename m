From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 34/39] dccp: drop null test before destroy functions
Date: Sun, 13 Sep 2015 14:15:27 +0200
Message-ID: <1442146532-9100-35-git-send-email-Julia.Lawall@lip6.fr>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unneeded NULL test.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x;
@@

-if (x != NULL)
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);

@@
expression x;
@@

-if (x != NULL) {
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
  x = NULL;
-}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/dccp/ackvec.c |   12 ++++--------
 net/dccp/ccid.c   |    3 +--
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 8349897..90f77d0 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -95,8 +95,7 @@ static struct kmem_cache *ccid_kmem_cache_create(int obj_size, char *slab_name_f
 
 static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 {
-	if (slab != NULL)
-		kmem_cache_destroy(slab);
+	kmem_cache_destroy(slab);
 }
 
 static int __init ccid_activate(struct ccid_operations *ccid_ops)
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index bd9e718..3de0d03 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -398,12 +398,8 @@ out_err:
 
 void dccp_ackvec_exit(void)
 {
-	if (dccp_ackvec_slab != NULL) {
-		kmem_cache_destroy(dccp_ackvec_slab);
-		dccp_ackvec_slab = NULL;
-	}
-	if (dccp_ackvec_record_slab != NULL) {
-		kmem_cache_destroy(dccp_ackvec_record_slab);
-		dccp_ackvec_record_slab = NULL;
-	}
+	kmem_cache_destroy(dccp_ackvec_slab);
+	dccp_ackvec_slab = NULL;
+	kmem_cache_destroy(dccp_ackvec_record_slab);
+	dccp_ackvec_record_slab = NULL;
 }
