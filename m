From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH]vxge-config.c: no need for check
Date: Wed, 10 Jun 2009 22:21:55 +0800
Message-ID: <1244643715.3422.8.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:30879 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbZFJOV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:21:56 -0400
Received: by rv-out-0506.google.com with SMTP id f9so268143rvb.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 07:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vfree() does its own 'NULL' check, so no need for check before
calling it.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
---   
drivers/net/vxge/vxge-config.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 6b41c88..26cde57 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -1884,17 +1884,13 @@ void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
 				mempool->memblock_size, dma_object);
 	}
 
-	if (mempool->items_arr)
-		vfree(mempool->items_arr);
+	vfree(mempool->items_arr);
 
-	if (mempool->memblocks_dma_arr)
-		vfree(mempool->memblocks_dma_arr);
+	vfree(mempool->memblocks_dma_arr);
 
-	if (mempool->memblocks_priv_arr)
-		vfree(mempool->memblocks_priv_arr);
+	vfree(mempool->memblocks_priv_arr);
 
-	if (mempool->memblocks_arr)
-		vfree(mempool->memblocks_arr);
+	vfree(mempool->memblocks_arr);
 
 	vfree(mempool);
 }


