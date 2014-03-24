From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/7] alx: Remove casts of pointer to same type
Date: Mon, 24 Mar 2014 13:15:35 -0700
Message-ID: <b8c7eec08a896af664e5ef18d1278504f450cfee.1395692043.git.joe@perches.com>
References: <cover.1395692043.git.joe@perches.com>
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 2e45f6e..6de1752 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -535,7 +535,7 @@ static int alx_alloc_descriptors(struct alx_priv *alx)
 	if (!alx->descmem.virt)
 		goto out_free;
 
-	alx->txq.tpd = (void *)alx->descmem.virt;
+	alx->txq.tpd = alx->descmem.virt;
 	alx->txq.tpd_dma = alx->descmem.dma;
 
 	/* alignment requirement for next block */
-- 
1.8.1.2.459.gbcd45b4.dirty
